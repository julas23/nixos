#!/usr/bin/env python3
import asyncio
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

import anthropic

API_KEY      = os.environ.get("ANTHROPIC_API_KEY", "")
WHISPER_MODEL = os.environ.get("JARVIS_MODEL",   "/var/lib/jarvis/models/ggml-large-v3-turbo.bin")
PIPER_MODEL   = os.environ.get("PIPER_MODEL",    "/var/lib/jarvis/models/pt_BR-faber-medium.onnx")
THREADS       = os.environ.get("JARVIS_THREADS", str(min(os.cpu_count() or 4, 8)))

SYSTEM_PROMPT = (
    "Você é Jarvis, assistente pessoal e interlocutor de confiança. "
    "Responda sempre em português brasileiro. Seja direto, perspicaz e analítico — "
    "sem rodeios, sem elogios vazios. "
    "Para conversação fluida: respostas curtas (2-3 frases no máximo). "
    "Para organização de ideias ou análise: pode desenvolver com estrutura clara. "
    "Quando o usuário apresentar muitas ideias ao mesmo tempo, ajude a nomear, "
    "organizar e priorizar sem perder nenhuma. "
    "IMPORTANTE: responda em texto puro, sem markdown, sem asteriscos, sem listas com traços."
)

C_RESET   = "\033[0m"
C_YELLOW  = "\033[33m"
C_CYAN    = "\033[36m"
C_GREEN   = "\033[32m"
C_MAGENTA = "\033[35m"
C_RED     = "\033[31m"



def load_history() -> list:
    history_path = Path(os.environ.get("JARVIS_HISTORY", os.path.expanduser("~/.local/share/jarvis/history.json")))
    if history_path.exists():
        try:
            return json.loads(history_path.read_text())
        except Exception:
            return []
    return []


def save_history(history: list) -> None:
    history_path = Path(os.environ.get("JARVIS_HISTORY", os.path.expanduser("~/.local/share/jarvis/history.json")))
    history_path.parent.mkdir(parents=True, exist_ok=True)
    history_path.write_text(json.dumps(history[-40:], ensure_ascii=False))


def record() -> str:
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
        path = f.name
    threshold = os.environ.get("JARVIS_THRESHOLD", "0.5%")
    print(f"{C_YELLOW}🎙  Ouvindo...{C_RESET}", flush=True)
    subprocess.run(
        ["sox", "-d", "-r", "16000", "-c", "1", path,
         "silence", "1", "0.2", threshold,
         "1", "2.5", threshold],
        check=True,
        stderr=subprocess.DEVNULL,
    )
    return path


def transcribe(audio_path: str) -> str:
    base = audio_path.replace(".wav", "")
    subprocess.run(
        ["whisper-cli",
         "-m", WHISPER_MODEL,
         "-f", audio_path,
         "-l", "pt",
         "-nt",
         "-t", THREADS,
         "-otxt",
         "-of", base],
        check=True,
        capture_output=True,
    )
    txt = Path(base + ".txt")
    text = txt.read_text().strip() if txt.exists() else ""
    if txt.exists():
        txt.unlink()
    Path(audio_path).unlink(missing_ok=True)
    return text


def strip_markdown(text: str) -> str:
    text = re.sub(r'\*{1,3}([^*]+?)\*{1,3}', r'\1', text)
    text = re.sub(r'^#{1,6}\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'`{1,3}[^`]*`{1,3}', '', text)
    text = re.sub(r'^\s*[-*+]\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'^\s*\d+\.\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', text)
    text = re.sub(r'^[-*_]{3,}\s*$', '', text, flags=re.MULTILINE)
    return re.sub(r'\n{3,}', '\n\n', text).strip()


async def speak_piper(text: str) -> None:
    """
    Piper gera WAV via stdout → mpv toca via stdin pipe.
    Zero latência de rede, geração local em ~100ms por frase.
    """
    piper_proc = subprocess.Popen(
        ["piper", "--model", PIPER_MODEL, "--output-file", "/dev/stdout"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )
    mpv_proc = subprocess.Popen(
        ["mpv", "--no-terminal", "--really-quiet", "-"],
        stdin=piper_proc.stdout,
        stderr=subprocess.DEVNULL,
    )
    piper_proc.stdout.close()  # deixa piper_proc receber SIGPIPE se mpv fechar
    piper_proc.stdin.write((text + "\n").encode("utf-8"))
    piper_proc.stdin.close()
    await asyncio.to_thread(piper_proc.wait)
    await asyncio.to_thread(mpv_proc.wait)


async def ask_and_speak(text: str, history: list) -> str:
    """
    Stream Claude → imprime tokens em tempo real → fala resposta completa via Piper.
    Com TTS local não há latência de rede para esconder: Piper gera áudio de uma
    resposta completa em < 1s. Pipeline simples é mais robusto que producer/consumer.
    """
    client = anthropic.AsyncAnthropic(api_key=API_KEY)
    history.append({"role": "user", "content": text})

    full_reply = ""

    print(f"{C_MAGENTA}Jarvis:{C_RESET} ", end="", flush=True)

    async with client.messages.stream(
        model="claude-haiku-4-5-20251001",
        max_tokens=600,
        system=SYSTEM_PROMPT,
        messages=history,
    ) as stream:
        async for delta in stream.text_stream:
            full_reply += delta
            print(delta, end="", flush=True)

    print("\n")

    await speak_piper(strip_markdown(full_reply))

    history.append({"role": "assistant", "content": full_reply})
    return full_reply


def check_prerequisites() -> None:
    if not API_KEY:
        sys.exit(
            f"{C_RED}Erro:{C_RESET} ANTHROPIC_API_KEY não definida.\n"
            "Configure em /etc/jarvis/env:\n"
            "  ANTHROPIC_API_KEY=sk-ant-..."
        )
    if not Path(WHISPER_MODEL).exists():
        sys.exit(
            f"{C_RED}Erro:{C_RESET} Modelo Whisper não encontrado: {WHISPER_MODEL}\n"
            "Execute: sudo jarvis-setup"
        )
    if not Path(PIPER_MODEL).exists():
        sys.exit(
            f"{C_RED}Erro:{C_RESET} Modelo Piper não encontrado: {PIPER_MODEL}\n"
            "Execute: sudo jarvis-setup"
        )


async def main_loop() -> None:
    check_prerequisites()
    history = load_history()

    print(f"Jarvis pronto  |  whisper: {Path(WHISPER_MODEL).name}  |  tts: {Path(PIPER_MODEL).stem}")
    print("Ctrl+C para encerrar.\n")

    while True:
        try:
            audio = record()

            print(f"{C_CYAN}🔄 Transcrevendo...{C_RESET}", flush=True)
            text = transcribe(audio)

            if not text or len(text.strip()) < 3:
                print("(não entendido, tente novamente)\n")
                continue

            print(f"{C_GREEN}Você:{C_RESET} {text}")

            reply = await ask_and_speak(text, history)
            save_history(history)

        except KeyboardInterrupt:
            save_history(history)
            print("\nAté logo.")
            break
        except subprocess.CalledProcessError as e:
            print(f"{C_RED}Erro no subprocesso:{C_RESET} {e}")
        except Exception as e:
            print(f"{C_RED}Erro:{C_RESET} {e}")


def main() -> None:
    asyncio.run(main_loop())


if __name__ == "__main__":
    main()
