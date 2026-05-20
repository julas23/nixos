#!/usr/bin/env python3
"""
Webcam MCP Server — captures a frame via OpenCV and returns it as base64 JPEG.

MCP tool exposed:
  capture_webcam()  → image/jpeg base64 content block

Installed by modules/ai/mcp.nix as the system binary `webcam-mcp`.
Claude Code config (~/.claude.json):
  "webcam": { "type": "stdio", "command": "webcam-mcp", "args": [] }
"""

import json
import sys
import base64
import cv2


def capture_frame() -> tuple[str | None, str | None]:
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        return None, "Failed to open /dev/video0 — check that the user is in the video group"
    try:
        ret, frame = cap.read()
        if not ret:
            return None, "Camera opened but failed to read a frame"
        ok, buf = cv2.imencode(".jpg", frame, [cv2.IMWRITE_JPEG_QUALITY, 90])
        if not ok:
            return None, "Failed to encode frame as JPEG"
        return base64.b64encode(buf.tobytes()).decode(), None
    finally:
        cap.release()


def handle(request: dict) -> dict | None:
    method = request.get("method", "")
    req_id = request.get("id")

    # Notifications have no id and require no response.
    if req_id is None:
        return None

    if method == "initialize":
        return {
            "jsonrpc": "2.0", "id": req_id,
            "result": {
                "protocolVersion": "2024-11-05",
                "serverInfo": {"name": "webcam-mcp", "version": "0.1.0"},
                "capabilities": {"tools": {}},
            },
        }

    if method == "tools/list":
        return {
            "jsonrpc": "2.0", "id": req_id,
            "result": {
                "tools": [{
                    "name": "capture_webcam",
                    "description": "Capture a frame from the default webcam and return it as a JPEG image",
                    "inputSchema": {"type": "object", "properties": {}, "required": []},
                }]
            },
        }

    if method == "tools/call":
        name = request.get("params", {}).get("name", "")
        if name == "capture_webcam":
            b64, err = capture_frame()
            if err:
                return {
                    "jsonrpc": "2.0", "id": req_id,
                    "result": {
                        "content": [{"type": "text", "text": f"Error: {err}"}],
                        "isError": True,
                    },
                }
            return {
                "jsonrpc": "2.0", "id": req_id,
                "result": {
                    "content": [{"type": "image", "data": b64, "mimeType": "image/jpeg"}],
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
            req = json.loads(line)
            resp = handle(req)
            if resp is not None:
                print(json.dumps(resp), flush=True)
        except json.JSONDecodeError as exc:
            sys.stderr.write(f"JSON parse error: {exc}\n")
        except Exception as exc:
            sys.stderr.write(f"Unhandled error: {exc}\n")


if __name__ == "__main__":
    main()
