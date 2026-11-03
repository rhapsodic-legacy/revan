# Agent guide: playing Dust of the Sun

This is for an AI playing the game through the DOTS API (`tools/dots-mcp`, or `agent/dots_stdio.gd` directly). It explains the combat rules you need to know. The full design is in `docs/bible/03_SYSTEMS.md`.

## Connect
```
claude mcp add dots -- env GODOT_BIN=/path/to/godot python3 tools/dots-mcp/dots_mcp.py
```
Tools: `list_arenas`, `load_arena {arena, seed, difficulty}`, `get_state`, `describe_map`, `act {id}`, `auto_turn`.

Without MCP: `godot --headless --path . --script agent/dots_stdio.gd`, then send one JSON object per line, e.g. `{"cmd":"load","arena":"deflector","seed":1}`.

## How a turn works
- The **timeline** (`state.timeline`) shows the next 12 turns. Faster units act more often.
- On your turn: **one move and one action**, in either order. Then send `end`.
  - `dash:x,y`: move up to twice as far, but no action.
  - `hold`: wait and act again soon (only before you've moved or acted).
- Everything you can do right now is in `state.legalActions`. Attacks include a `preview` with hit %, damage range, crit %, facing (`front`, `flank`, `back`) and `reflected_by`.
- Enemy turns run automatically. You get control back when a party member is up.

## Rules that matter
- **Facing:** hitting from the flank (+20% hit, +15% damage) or the back (+40% hit, +30% damage) is much better. Units turn to face whoever last hit them.
- **High ground** (`^` on the map): +15% hit, +10% damage, +2 range.
- **Cover** (`=`): −25% to ranged shots at a unit tucked behind it.
- **Attacks of opportunity:** leaving an enemy's melee reach lets them hit you.
- **Poise:** heavy hits break Poise. A Staggered unit loses its next turn and takes +50% damage.
- **Downed:** a party member at 0 HP is Downed for 3 of their turns. An adjacent ally can `revive:<id>`. **If Dust goes Out, the fight is lost.**
- **Doors** (`+` closed, `/` open, `X` locked): closed doors block sight and movement. `door:x,y` toggles one. Deena and K'saabu can `lock:x,y`, so enemies must `break` it. Splitting a group with a door is a legitimate tactic.
- **Deflectors:** a unit with `"deflector": true` reflects ranged shots and cannon blasts aimed within 2 tiles of it back at the shooter. Check `reflected_by` before you fire. Answers: melee, shoving, doors, or `search` to find its generator and shoot that (shots at the generator aren't reflected).
- **K'saabu's cannon** always hits a 3×3 area, including allies, civilians and fragile objects. `preview.hits` lists everyone it would hit.
- **Search** (`search`): rolls Perception against hidden Insights in the fight. Deena is best at it.
- **Pass Turn** (`pass:<ally>`, Deena only, cooldown 3): Deena gives her turn to an ally, who acts right now.
- **Civilians:** `shove:<civilian>` always works and moves them out of the line of fire.
- **Explosive objects** (like a fuel cell) blow up in a 3×3 when destroyed.

## A good loop
1. `describe_map` to see the board.
2. `get_state` and read `legalActions` with their previews.
3. Pick a move that gets a flank or back attack, high ground, or cover.
4. Act, then `end`.
5. Unsure? `auto_turn` lets the built-in tactics play that turn.
