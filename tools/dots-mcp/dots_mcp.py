#!/usr/bin/env python3
"""MCP server that lets any MCP-capable AI play Dust of the Sun (bible 03 §11.3).

No dependencies. It starts the game headless and relays tool calls to the DOTS stdio API.

  GODOT_BIN=/path/to/godot python3 tools/dots-mcp/dots_mcp.py

Claude Code: claude mcp add dots -- env GODOT_BIN=/path/to/godot python3 tools/dots-mcp/dots_mcp.py
"""
import json
import os
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
GODOT = os.environ.get("GODOT_BIN", "godot")

TOOLS = [
    {"name": "list_arenas", "description": "List the playable arenas.", "inputSchema": {"type": "object", "properties": {}}},
    {"name": "load_arena", "description": "Start a fight. Enemy turns run automatically until it's your party's turn.",
     "inputSchema": {"type": "object", "properties": {
         "arena": {"type": "string"}, "seed": {"type": "integer"},
         "difficulty": {"type": "string", "enum": ["story", "seer", "vors"]}}, "required": ["arena"]}},
    {"name": "get_state", "description": "Full game state: units, timeline, doors, insights, legalActions (with hit/damage previews), log.",
     "inputSchema": {"type": "object", "properties": {}}},
    {"name": "describe_map", "description": "ASCII top-down map of the combat grid with a unit legend. * marks whose turn it is.",
     "inputSchema": {"type": "object", "properties": {}}},
    {"name": "act", "description": "Take one legal action by id, e.g. 'move:4,2', 'attack:thug_1', 'cannon:7,2', 'door:6,3', 'lock:6,3', 'search', 'pass:ksaabu', 'end'. A turn is one move plus one action; call 'end' when done.",
     "inputSchema": {"type": "object", "properties": {"id": {"type": "string"}}, "required": ["id"]}},
    {"name": "auto_turn", "description": "Let Standing Orders (the built-in AI) play the current party member's turn.",
     "inputSchema": {"type": "object", "properties": {}}},
]
CMD = {"list_arenas": "arenas", "load_arena": "load", "get_state": "state", "describe_map": "map", "act": "act", "auto_turn": "auto"}


class Game:
    def __init__(self):
        self.p = subprocess.Popen([GODOT, "--headless", "--path", ROOT, "--script", "agent/dots_stdio.gd"],
                                  stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, bufsize=1)
        self._read()  # hello line

    def _read(self):
        while True:
            line = self.p.stdout.readline()
            if not line:
                raise RuntimeError("game process exited")
            line = line.strip()
            if line.startswith("{"):
                return json.loads(line)

    def call(self, req):
        self.p.stdin.write(json.dumps(req) + "\n")
        self.p.stdin.flush()
        return self._read()


game = None


def handle(msg):
    global game
    method, mid = msg.get("method"), msg.get("id")
    if method == "initialize":
        return {"jsonrpc": "2.0", "id": mid, "result": {
            "protocolVersion": msg.get("params", {}).get("protocolVersion", "2025-06-18"),
            "capabilities": {"tools": {}},
            "serverInfo": {"name": "dots", "version": "0.1.0"},
            "instructions": "Play Dust of the Sun. Read docs/AGENT_GUIDE.md for the rules. Start with list_arenas and load_arena."}}
    if method == "tools/list":
        return {"jsonrpc": "2.0", "id": mid, "result": {"tools": TOOLS}}
    if method == "tools/call":
        name = msg["params"]["name"]
        args = msg["params"].get("arguments", {}) or {}
        if game is None:
            game = Game()
        req = {"cmd": CMD[name]}
        req.update(args)
        res = game.call(req)
        text = res.get("map") if name == "describe_map" and res.get("ok") else json.dumps(res, indent=1)
        return {"jsonrpc": "2.0", "id": mid, "result": {"content": [{"type": "text", "text": text}], "isError": not res.get("ok", False)}}
    if mid is None:
        return None  # notification
    return {"jsonrpc": "2.0", "id": mid, "error": {"code": -32601, "message": "Method not found"}}


def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        out = handle(json.loads(line))
        if out is not None:
            sys.stdout.write(json.dumps(out) + "\n")
            sys.stdout.flush()


if __name__ == "__main__":
    main()
