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
VOICE      = os.environ.get("JARVIS_VOICE", "pt-BR-AntonioNeural")
HISTORY    = Path(os.environ.get("JARVIS_HISTORY", os.path.expanduser("~/.local/share/jarvis/history.json")))
THREADS    = os.environ.get("JARVIS_THREADS", str(min(os.cpu_count() or 4, 8)))

SYSTEM_PROMPT = (
    "Você é Jarvis, assistente pessoal e interlocutor de confiança. "
    "Responda sempre em português brasileiro. Seja direto, perspicaz e analítico — "
    "sem rodeios, sem elogios vazios. "
    "Para conversação fluida: respostas curtas (2-3 frases no máximo). "
    "Para organização de ideias ou análise: pode desenvolver com estrutura clara. "
    "Quando o usuário apresentar muitas ideias ao mesmo tempo, ajude a nomear, "
    "organizar e priorizar sem perder nenhuma."
)

C_RESET  = "\033[0m"
C_YELLOW = "\033[33m"
C_CYAN   = "\033[36m"
C_GREEN  = "\033[32m"
C_MAGENTA = "\033[35m"
C_RED    = "\033[31m"


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


def ask_claude(text: str, history: list) -> str:
    client = anthropic.Anthropic(api_key=API_KEY)
    history.append({"role": "user", "content": text})
    response = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=600,
        system=SYSTEM_PROMPT,
        messages=history,
    )
    reply = response.content[0].text
    history.append({"role": "assistant", "content": reply})
    return reply


def strip_markdown(text: str) -> str:
    text = re.sub(r'\*{1,3}([^*]+?)\*{1,3}', r'\1', text)
    text = re.sub(r'^#{1,6}\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'`{1,3}[^`]*`{1,3}', '', text)
    text = re.sub(r'^\s*[-*+]\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'^\s*\d+\.\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', text)
    text = re.sub(r'^[-*_]{3,}\s*$', '', text, flags=re.MULTILINE)
    return re.sub(r'\n{3,}', '\n\n', text).strip()


async def speak(text: str) -> None:
    with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as f:
        out = f.name
    await edge_tts.Communicate(text, VOICE).save(out)
    subprocess.run(["mpv", "--no-terminal", "--really-quiet", out])
    Path(out).unlink(missing_ok=True)


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


def main() -> None:
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

            print(f"{C_CYAN}💭  Pensando...{C_RESET}", flush=True)
            reply = ask_claude(text, history)
            save_history(history)

            print(f"{C_MAGENTA}Jarvis:{C_RESET} {reply}\n")
            asyncio.run(speak(strip_markdown(reply)))

        except KeyboardInterrupt:
            save_history(history)
            print("\nAté logo.")
            break
        except subprocess.CalledProcessError as e:
            print(f"{C_RED}Erro no subprocesso:{C_RESET} {e}")
        except Exception as e:
            print(f"{C_RED}Erro:{C_RESET} {e}")


if __name__ == "__main__":
    main()
