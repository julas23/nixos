# AI Stack — MCP Servers for Claude Code
#
# Builds two MCP server scripts as Nix derivations (available in PATH system-wide):
#   webcam-mcp    captures a webcam frame → image/jpeg base64 (requires opencv)
#   comfyui-mcp   queues image generation via ComfyUI REST API (stdlib only)
#
# After enabling, add the following to ~/.claude.json mcpServers:
#
#   "voice": {
#     "type": "stdio", "command": "uvx",
#     "args": ["--refresh", "--with", "webrtcvad", "voice-mode"]
#   },
#   "memory": {
#     "type": "stdio", "command": "npx",
#     "args": ["-y", "@modelcontextprotocol/server-memory"]
#   },
#   "webcam": {
#     "type": "stdio", "command": "webcam-mcp", "args": []
#   },
#   "comfyui": {
#     "type": "stdio", "command": "comfyui-mcp", "args": []
#   }
#
# The reference JSON is also written to /etc/ai/claude-mcp-example.json.

{ config, lib, pkgs, ... }:

let
  aiEnabled = config.system.config.ai.enable;

  webcamMcp = pkgs.writers.writePython3Bin "webcam-mcp"
    { libraries = with pkgs.python3Packages; [ opencv4 ]; }
    (builtins.readFile ./mcp-servers/webcam_mcp.py);

  comfyuiMcp = pkgs.writers.writePython3Bin "comfyui-mcp"
    { libraries = []; }
    (builtins.readFile ./mcp-servers/comfyui_mcp.py);

  mcpExampleConfig = {
    mcpServers = {
      voice = {
        type    = "stdio";
        command = "uvx";
        args    = [ "--refresh" "--with" "webrtcvad" "voice-mode" ];
      };
      memory = {
        type    = "stdio";
        command = "npx";
        args    = [ "-y" "@modelcontextprotocol/server-memory" ];
      };
      webcam = {
        type    = "stdio";
        command = "webcam-mcp";
        args    = [];
      };
      comfyui = {
        type    = "stdio";
        command = "comfyui-mcp";
        args    = [];
      };
    };
  };
in

{
  config = lib.mkIf aiEnabled {
    # Put both MCP servers in PATH system-wide.
    environment.systemPackages = [ webcamMcp comfyuiMcp ];

    # Reference config for the user to copy/merge into ~/.claude.json.
    environment.etc."ai/claude-mcp-example.json".text =
      builtins.toJSON mcpExampleConfig;
  };
}
