#!/usr/bin/env python3
"""
ComfyUI MCP Server — queues image generation via the ComfyUI REST API.

MCP tool exposed:
  generate_image(prompt, negative_prompt?, steps?, width?, height?)
    → text confirmation with prompt_id; output saved to /data/ai/comfyui/output/

Requires ComfyUI running at http://localhost:8188 (docker-comfyui.service).
Installed by modules/ai/mcp.nix as the system binary `comfyui-mcp`.
Claude Code config (~/.claude.json):
  "comfyui": { "type": "stdio", "command": "comfyui-mcp", "args": [] }
"""

import json
import sys
import time
import uuid
import urllib.error
import urllib.request

COMFYUI_URL = "http://localhost:8188"
SERVER_INFO  = {"name": "comfyui-mcp", "version": "0.1.0"}


def _build_workflow(prompt: str, negative: str, steps: int, width: int, height: int) -> dict:
    """Minimal SD 1.5 workflow. Users can swap the checkpoint in ComfyUI's UI."""
    seed = int(time.time()) % (2 ** 32)
    return {
        "4":  {"class_type": "CheckpointLoaderSimple",
               "inputs": {"ckpt_name": "v1-5-pruned-emaonly.ckpt"}},
        "5":  {"class_type": "EmptyLatentImage",
               "inputs": {"batch_size": 1, "height": height, "width": width}},
        "6":  {"class_type": "CLIPTextEncode",
               "inputs": {"clip": ["4", 1], "text": prompt}},
        "7":  {"class_type": "CLIPTextEncode",
               "inputs": {"clip": ["4", 1], "text": negative}},
        "3":  {"class_type": "KSampler",
               "inputs": {
                   "cfg": 7, "denoise": 1, "latent_image": ["5", 0],
                   "model": ["4", 0], "negative": ["7", 0], "positive": ["6", 0],
                   "sampler_name": "euler", "scheduler": "normal",
                   "seed": seed, "steps": steps,
               }},
        "8":  {"class_type": "VAEDecode",
               "inputs": {"samples": ["3", 0], "vae": ["4", 2]}},
        "9":  {"class_type": "SaveImage",
               "inputs": {"filename_prefix": "mcp", "images": ["8", 0]}},
    }


def queue_prompt(prompt: str, negative: str, steps: int, width: int, height: int) -> str:
    workflow  = _build_workflow(prompt, negative, steps, width, height)
    client_id = str(uuid.uuid4())
    payload   = json.dumps({"prompt": workflow, "client_id": client_id}).encode()
    req = urllib.request.Request(
        f"{COMFYUI_URL}/prompt",
        data=payload,
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.loads(resp.read()).get("prompt_id", "unknown")


def handle(request: dict) -> dict | None:
    method = request.get("method", "")
    req_id = request.get("id")

    if req_id is None:
        return None

    if method == "initialize":
        return {
            "jsonrpc": "2.0", "id": req_id,
            "result": {
                "protocolVersion": "2024-11-05",
                "serverInfo": SERVER_INFO,
                "capabilities": {"tools": {}},
            },
        }

    if method == "tools/list":
        return {
            "jsonrpc": "2.0", "id": req_id,
            "result": {
                "tools": [{
                    "name": "generate_image",
                    "description": (
                        "Generate an image with Stable Diffusion via ComfyUI. "
                        "Output is saved to /data/ai/comfyui/output/."
                    ),
                    "inputSchema": {
                        "type": "object",
                        "properties": {
                            "prompt":          {"type": "string", "description": "Positive prompt"},
                            "negative_prompt": {"type": "string", "description": "Negative prompt", "default": ""},
                            "steps":           {"type": "integer", "description": "Inference steps", "default": 20},
                            "width":           {"type": "integer", "description": "Width in pixels",  "default": 512},
                            "height":          {"type": "integer", "description": "Height in pixels", "default": 512},
                        },
                        "required": ["prompt"],
                    },
                }]
            },
        }

    if method == "tools/call":
        params = request.get("params", {})
        if params.get("name") == "generate_image":
            args = params.get("arguments", {})
            try:
                prompt_id = queue_prompt(
                    args.get("prompt", ""),
                    args.get("negative_prompt", ""),
                    args.get("steps", 20),
                    args.get("width", 512),
                    args.get("height", 512),
                )
                return {
                    "jsonrpc": "2.0", "id": req_id,
                    "result": {
                        "content": [{
                            "type": "text",
                            "text": (
                                f"Image queued — prompt_id: {prompt_id}\n"
                                f"Output → /data/ai/comfyui/output/\n"
                                f"Monitor at http://localhost:8188"
                            ),
                        }]
                    },
                }
            except urllib.error.URLError as exc:
                return {
                    "jsonrpc": "2.0", "id": req_id,
                    "result": {
                        "content": [{"type": "text", "text": f"Cannot reach ComfyUI: {exc}"}],
                        "isError": True,
                    },
                }

    return {
        "jsonrpc": "2.0", "id": req_id,
        "error": {"code": -32601, "message": f"Method not found: {method}"},
    }


def main() -> None:
    for raw_line in sys.stdin:
        line = raw_line.strip()
        if not line:
            continue
        try:
            req  = json.loads(line)
            resp = handle(req)
            if resp is not None:
                print(json.dumps(resp), flush=True)
        except json.JSONDecodeError as exc:
            sys.stderr.write(f"JSON parse error: {exc}\n")
        except Exception as exc:
            sys.stderr.write(f"Unhandled error: {exc}\n")


if __name__ == "__main__":
    main()
