# Dust of the Sun

A turn-based, grid-based RPG in Godot 4. The design bible is in [`docs/bible/`](docs/bible/README.md).

## Status: M1, engine core
The rules engine runs headless (no scene tree), so tests and AI players can drive it directly.

| Piece | Where |
|---|---|
| Rules: grid, timeline, actions, facing, height, cover, doors, Deflectors, collateral, Downed/revive, Pass Turn, Search | `engine/combat.gd`, `engine/grid.gd`, `engine/unit.gd` |
| Utility AI (enemies, and the party's Standing Orders autoplay) | `engine/ai.gd` |
| Characters and test arenas (JSON) | `data/` |
| AI-play API (DOTS) over stdio, plus an MCP server | `agent/`, `tools/dots-mcp/`, [`docs/AGENT_GUIDE.md`](docs/AGENT_GUIDE.md) |
| Placeholder-box viewer | `world/arena_view.tscn` (main scene) |
| Tests (rules + AI autoplay of every arena) | `tests/`, run in GitHub Actions |

## Run
```sh
godot --path .                                                 # viewer: Space step, A autoplay, N next arena
godot --headless --path . --script tests/run_tests.gd          # tests
godot --headless --path . --script agent/dots_stdio.gd         # agent API (JSON lines)
```
Requires Godot 4.3+.
