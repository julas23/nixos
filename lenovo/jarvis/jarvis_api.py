#!/usr/bin/env python3
"""Jarvis API — OpenAI-compatible server for OpenWebUI integration."""

import asyncio
import json
import os
import subprocess
import tempfile
import time
import uuid
from pathlib import Path

import anthropic
from faster_whisper import WhisperModel
from fastapi import FastAPI, File, Form, UploadFile
from fastapi.responses import Response, StreamingResponse
from pydantic import BaseModel

ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")
PIPER_MODEL       = os.environ.get("PIPER_MODEL", "/DATA/jarvis/models/pt_BR-faber-medium.onnx")
PIPER_BIN         = os.environ.get("PIPER_BIN",   "/DATA/jarvis/env/bin/piper")
WHISPER_MODEL_ID  = os.environ.get("WHISPER_MODEL", "large-v3")
CLAUDE_MODEL      = os.environ.get("CLAUDE_MODEL", "claude-haiku-4-5-20251001")

SYSTEM_PROMPT = (
    "Você é Jarvis, assistente pessoal e interlocutor de confiança. "
    "Responda sempre em português brasileiro. Seja direto, perspicaz e analítico — "
    "sem rodeios, sem elogios vazios. "
    "Para conversação fluida: respostas curtas (2-3 frases no máximo). "
    "Para organização de ideias ou análise: pode desenvolver com estrutura clara. "
    "Quando o usuário apresentar muitas ideias ao mesmo tempo, ajude a nomear, "
    "organizar e priorizar sem perder nenhuma."
)

app = FastAPI(title="Jarvis API")

_whisper: WhisperModel | None = None


def get_whisper() -> WhisperModel:
    global _whisper
    if _whisper is None:
        _whisper = WhisperModel(WHISPER_MODEL_ID, device="cuda", compute_type="int8")
    return _whisper


class Message(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    model: str = "jarvis"
    messages: list[Message]
    stream: bool = False
    max_tokens: int = 600


class SpeechRequest(BaseModel):
    model: str = "tts-1"
    input: str
    voice: str = "faber"
    response_format: str = "wav"


@app.get("/v1/models")
async def list_models():
    return {
        "object": "list",
        "data": [{"id": "jarvis", "object": "model", "created": 0, "owned_by": "jarvis"}],
    }


@app.post("/v1/audio/transcriptions")
async def transcribe_audio(
    file: UploadFile = File(...),
    model: str = Form("whisper-1"),
    language: str = Form("pt"),
):
    with tempfile.NamedTemporaryFile(suffix=Path(file.filename or "audio.wav").suffix or ".wav", delete=False) as f:
        f.write(await file.read())
        tmp_audio = f.name
    try:
        whisper = await asyncio.to_thread(get_whisper)
        segments, _ = await asyncio.to_thread(
            whisper.transcribe, tmp_audio, language=language, beam_size=5
        )
        text = " ".join(s.text for s in segments).strip()
        return {"text": text}
    finally:
        Path(tmp_audio).unlink(missing_ok=True)


async def _stream_chat(messages: list[dict], max_tokens: int):
    client = anthropic.AsyncAnthropic(api_key=ANTHROPIC_API_KEY)
    cid = f"chatcmpl-{uuid.uuid4().hex[:8]}"
    created = int(time.time())

    yield f"data: {json.dumps({'id': cid, 'object': 'chat.completion.chunk', 'created': created, 'model': 'jarvis', 'choices': [{'index': 0, 'delta': {'role': 'assistant'}, 'finish_reason': None}]})}\n\n"

    async with client.messages.stream(
        model=CLAUDE_MODEL,
        max_tokens=max_tokens,
        system=SYSTEM_PROMPT,
        messages=messages,
    ) as stream:
        async for delta in stream.text_stream:
            yield f"data: {json.dumps({'id': cid, 'object': 'chat.completion.chunk', 'created': created, 'model': 'jarvis', 'choices': [{'index': 0, 'delta': {'content': delta}, 'finish_reason': None}]})}\n\n"

    yield f"data: {json.dumps({'id': cid, 'object': 'chat.completion.chunk', 'created': created, 'model': 'jarvis', 'choices': [{'index': 0, 'delta': {}, 'finish_reason': 'stop'}]})}\n\n"
    yield "data: [DONE]\n\n"


@app.post("/v1/chat/completions")
async def chat_completions(req: ChatRequest):
    messages = [{"role": m.role, "content": m.content} for m in req.messages if m.role != "system"]

    if req.stream:
        return StreamingResponse(
            _stream_chat(messages, req.max_tokens),
            media_type="text/event-stream",
            headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"},
        )

    client = anthropic.AsyncAnthropic(api_key=ANTHROPIC_API_KEY)
    response = await client.messages.create(
        model=CLAUDE_MODEL,
        max_tokens=req.max_tokens,
        system=SYSTEM_PROMPT,
        messages=messages,
    )
    content = response.content[0].text
    return {
        "id": f"chatcmpl-{uuid.uuid4().hex[:8]}",
        "object": "chat.completion",
        "created": int(time.time()),
        "model": "jarvis",
        "choices": [{"index": 0, "message": {"role": "assistant", "content": content}, "finish_reason": "stop"}],
        "usage": {
            "prompt_tokens": response.usage.input_tokens,
            "completion_tokens": response.usage.output_tokens,
            "total_tokens": response.usage.input_tokens + response.usage.output_tokens,
        },
    }


@app.post("/v1/audio/speech")
async def text_to_speech(req: SpeechRequest):
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
        tmp_wav = f.name
    try:
        await asyncio.to_thread(
            subprocess.run,
            [PIPER_BIN, "--model", PIPER_MODEL, "--output-file", tmp_wav],
            input=(req.input + "\n").encode("utf-8"),
            stderr=subprocess.DEVNULL,
            check=True,
        )
        audio = Path(tmp_wav).read_bytes()
        return Response(content=audio, media_type="audio/wav")
    finally:
        Path(tmp_wav).unlink(missing_ok=True)
