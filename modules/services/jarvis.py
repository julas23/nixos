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
import edge_tts

API_KEY    = os.environ.get("ANTHROPIC_API_KEY", "")
MODEL_PATH = os.environ.get("JARVIS_MODEL", "/var/lib/jarvis/models/ggml-large-v3-turbo.bin")
VOICE      = os.environ.get("JARVIS_VOICE", "pt-BR-ThalitaNeural")
HISTORY    = Path(os.environ.get("JARVIS_HISTORY", os.path.expanduser("~/.local/share/jarvis/history.json")))
THREADS    = os.environ.get("JARVIS_THREADS", str(min(os.cpu_count() or 4, 8)))

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

# Detecta fim de frase: ponto/exclamação/interrogação seguido de espaço
SENTENCE_END = re.compile(r'(?<=[.!?…])\s+')
# Tamanho mínimo de frase para enviar ao TTS (evita fragmentos curtos)
MIN_SENTENCE = 15


def load_history() -> list:
    if HISTORY.exists():
        try:
            return json.loads(HISTORY.read_text())
        except Exception:
            return []
    return []


def save_history(history: list) -> None:
    HISTORY.parent.mkdir(parents=True, exist_ok=True)
    HISTORY.write_text(json.dumps(history[-40:], ensure_ascii=False))


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
         "-m", MODEL_PATH,
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


async def prefetch_audio(text: str) -> bytes:
    """Busca todos os chunks de áudio do Edge TTS em memória."""
    communicate = edge_tts.Communicate(text, VOICE)
    data = b""
    async for chunk in communicate.stream():
        if chunk["type"] == "audio":
            data += chunk["data"]
    return data


async def play_bytes(data: bytes) -> None:
    """Envia bytes de áudio para mpv via pipe. asyncio.to_thread libera o event loop durante playback."""
    proc = subprocess.Popen(
        ["mpv", "--no-terminal", "--really-quiet", "-"],
        stdin=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )
    try:
        proc.stdin.write(data)
        proc.stdin.close()
    except BrokenPipeError:
        pass
    await asyncio.to_thread(proc.wait)


async def ask_and_speak(text: str, history: list) -> str:
    """
    Pipeline producer/consumer totalmente assíncrono:
      producer: AsyncAnthropic stream → buffer → frase → prefetch TTS → fila
      consumer: fila → play_bytes (mpv)
    asyncio.gather roda ambos em paralelo — enquanto mpv toca a frase N,
    o TTS da frase N+1 já está sendo pré-buscado.
    """
    client = anthropic.AsyncAnthropic(api_key=API_KEY)
    history.append({"role": "user", "content": text})

    full_reply = ""
    buffer = ""
    audio_queue: asyncio.Queue = asyncio.Queue(maxsize=3)

    print(f"{C_MAGENTA}Jarvis:{C_RESET} ", end="", flush=True)

    async def producer() -> None:
        nonlocal full_reply, buffer
        try:
            async with client.messages.stream(
                model="claude-haiku-4-5-20251001",
                max_tokens=600,
                system=SYSTEM_PROMPT,
                messages=history,
            ) as stream:
                async for delta in stream.text_stream:
                    full_reply += delta
                    buffer += delta
                    print(delta, end="", flush=True)

                    parts = SENTENCE_END.split(buffer, maxsplit=1)
                    if len(parts) > 1 and len(parts[0]) >= MIN_SENTENCE:
                        audio = await prefetch_audio(strip_markdown(parts[0]))
                        await audio_queue.put(audio)
                        buffer = parts[1]

            # Flush qualquer texto restante
            if buffer.strip():
                audio = await prefetch_audio(strip_markdown(buffer))
                await audio_queue.put(audio)
        finally:
            await audio_queue.put(None)  # sentinel: sinaliza fim ao consumer

    async def consumer() -> None:
        while True:
            audio = await audio_queue.get()
            if audio is None:
                break
            await play_bytes(audio)

    await asyncio.gather(producer(), consumer())
    print("\n")

    history.append({"role": "assistant", "content": full_reply})
    return full_reply


def check_prerequisites() -> None:
    if not API_KEY:
        sys.exit(
            f"{C_RED}Erro:{C_RESET} ANTHROPIC_API_KEY não definida.\n"
            "Configure em /etc/jarvis/env:\n"
            "  ANTHROPIC_API_KEY=sk-ant-..."
        )
    if not Path(MODEL_PATH).exists():
        sys.exit(
            f"{C_RED}Erro:{C_RESET} Modelo não encontrado: {MODEL_PATH}\n"
            "Execute como root:\n"
            "  jarvis-setup"
        )


async def main_loop() -> None:
    check_prerequisites()
    history = load_history()

    print(f"Jarvis pronto  |  modelo: {Path(MODEL_PATH).name}  |  voz: {VOICE}")
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
