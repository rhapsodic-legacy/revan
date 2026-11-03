# Dust of the Sun

A turn-based, grid-based RPG in Godot 4. The design bible is in [`docs/bible/`](docs/bible/README.md).

## Status: M2 in progress, the playable Opening
The rules engine runs headless (no scene tree), so tests and AI players can drive it directly.

| Piece | Where |
|---|---|
| Rules: grid, timeline, actions, facing, height, cover, doors, Deflectors, collateral, Downed/revive, Pass Turn, Search | `engine/combat.gd`, `engine/grid.gd`, `engine/unit.gd` |
| Utility AI (enemies, and the party's Standing Orders autoplay) | `engine/ai.gd` |
| Characters and test arenas (JSON) | `data/` |
| AI-play API (DOTS) over stdio, plus an MCP server | `agent/`, `tools/dots-mcp/`, [`docs/AGENT_GUIDE.md`](docs/AGENT_GUIDE.md) |
| Placeholder-box viewer | `world/arena_view.tscn` (main scene) |
| Tests (rules + AI autoplay of every arena) | `tests/`, run in GitHub Actions |

The Opening ("Fast and Hard", `docs/bible/05_OPENING_SCENARIO.md`) plays start to finish: scenes, choices, the three tutorial fights, Altitude, landing, the tip-off. Dialogue is pulled from the bible by line ID (`tools/scenario/extract_lines.py`). Art is placeholder blockout with a low-res dithered retro pass.

## Run
```sh
godot --path .                                                 # play the Opening (click/Space to advance; click tiles to move, enemies to attack)
godot --path . -- --auto                                       # watch the AI play it
godot --path . world/arena_view.tscn                           # test-arena viewer
godot --headless --path . --script tests/run_tests.gd          # tests
godot --headless --path . --script agent/dots_stdio.gd         # agent API (JSON lines): {"cmd":"play","scenario":"opening"}
```
Requires Godot 4.3+.
