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
from faster_whisper import WhisperModel

ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")
WHISPER_MODEL_ID  = os.environ.get("WHISPER_MODEL",  "large-v3")
PIPER_MODEL       = os.environ.get("PIPER_MODEL",    "/DATA/jarvis/models/pt_BR-faber-medium.onnx")
PIPER_BIN         = os.environ.get("PIPER_BIN",      "/DATA/jarvis/env/bin/piper")
HISTORY_FILE      = Path(os.environ.get("JARVIS_HISTORY", "/DATA/jarvis/history.json"))

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

_whisper: WhisperModel | None = None


def get_whisper() -> WhisperModel:
    global _whisper
    if _whisper is None:
        print(f"{C_CYAN}Carregando Whisper na GPU ({WHISPER_MODEL_ID})...{C_RESET}", flush=True)
        _whisper = WhisperModel(WHISPER_MODEL_ID, device="cuda", compute_type="int8")
        print("Whisper pronto.", flush=True)
    return _whisper


def load_history() -> list:
    if HISTORY_FILE.exists():
        try:
            return json.loads(HISTORY_FILE.read_text())
        except Exception:
            return []
    return []


def save_history(history: list) -> None:
    HISTORY_FILE.parent.mkdir(parents=True, exist_ok=True)
    HISTORY_FILE.write_text(json.dumps(history[-40:], ensure_ascii=False))


def record() -> str:
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
        path = f.name
    threshold = os.environ.get("JARVIS_THRESHOLD", "0.5%")
    print(f"{C_YELLOW}🎙  Ouvindo...{C_RESET}", flush=True)
    subprocess.run(
        ["sox", "-d", "-r", "16000", "-c", "1", path,
         "silence", "1", "0.2", threshold, "1", "2.5", threshold],
        check=True, stderr=subprocess.DEVNULL,
    )
    return path


def transcribe(audio_path: str) -> str:
    model = get_whisper()
    segments, _ = model.transcribe(audio_path, language="pt", beam_size=5)
    text = " ".join(s.text for s in segments).strip()
    Path(audio_path).unlink(missing_ok=True)
    return text


def strip_markdown(text: str) -> str:
    text = re.sub(r'\*{1,3}([^*]+?)\*{1,3}', r'\1', text)
    text = re.sub(r'^#{1,6}\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'`{1,3}[^`]*`{1,3}', '', text)
    text = re.sub(r'^\s*[-*+]\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'^\s*\d+\.\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', text)
    return re.sub(r'\n{3,}', '\n\n', text).strip()


async def speak_piper(text: str) -> None:
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
        tmp_wav = f.name
    try:
        await asyncio.to_thread(subprocess.run,
            [PIPER_BIN, "--model", PIPER_MODEL, "--output-file", tmp_wav],
            input=(text + "\n").encode("utf-8"),
            stderr=subprocess.DEVNULL, check=True,
        )
        await asyncio.to_thread(subprocess.run,
            ["mpv", "--no-terminal", "--really-quiet", tmp_wav],
            stderr=subprocess.DEVNULL,
        )
    finally:
        Path(tmp_wav).unlink(missing_ok=True)


async def ask_and_speak(text: str, history: list) -> str:
    client = anthropic.AsyncAnthropic(api_key=ANTHROPIC_API_KEY)
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
    if not ANTHROPIC_API_KEY:
        sys.exit(f"{C_RED}Erro:{C_RESET} ANTHROPIC_API_KEY não definida em /DATA/jarvis/.env")
    if not Path(PIPER_MODEL).exists():
        sys.exit(f"{C_RED}Erro:{C_RESET} Modelo Piper não encontrado: {PIPER_MODEL}")
    if not Path(PIPER_BIN).exists():
        sys.exit(f"{C_RED}Erro:{C_RESET} Piper não encontrado: {PIPER_BIN}")


async def main_loop() -> None:
    check_prerequisites()
    get_whisper()  # carrega na GPU antes do primeiro uso
    history = load_history()

    print(f"\nJarvis pronto  |  whisper: {WHISPER_MODEL_ID} (CUDA)  |  tts: {Path(PIPER_MODEL).stem}")
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
            print(f"{C_RED}Erro subprocesso:{C_RESET} {e}")
        except Exception as e:
            print(f"{C_RED}Erro:{C_RESET} {e}")


def main() -> None:
    asyncio.run(main_loop())


if __name__ == "__main__":
    main()
