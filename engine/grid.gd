## The 1 m tactical grid (bible 03 §6). Tiles, walls, doors, water, height, half cover.
## Built from an ASCII map so arenas are plain text an AI session can author.
##
## Legend:
##   .  floor            #  wall            ~  water (passable)
##   +  closed door      /  open door       =  half cover (crate; blocks movement)
##   ^  high ground (height 1 floor)
extends RefCounted

var width := 0
var height := 0
var tiles := {}       # Vector2i -> {"kind": String, "h": int}
var doors := {}       # Vector2i -> {"open": bool, "hp": int, "max_hp": int}

const DIRS8 := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]

static func from_rows(rows: Array, door_hp: int = 60) -> RefCounted:
	var g = load("res://engine/grid.gd").new()
	g.height = rows.size()
	for y in rows.size():
		var row: String = rows[y]
		g.width = maxi(g.width, row.length())
		for x in row.length():
			var c := row[x]
			var p := Vector2i(x, y)
			match c:
				"#": g.tiles[p] = {"kind": "wall", "h": 0}
				"~": g.tiles[p] = {"kind": "water", "h": 0}
				"=": g.tiles[p] = {"kind": "cover", "h": 0}
				"^": g.tiles[p] = {"kind": "floor", "h": 1}
				"+":
					g.tiles[p] = {"kind": "door", "h": 0}
					g.doors[p] = {"open": false, "hp": door_hp, "max_hp": door_hp}
				"/":
					g.tiles[p] = {"kind": "door", "h": 0}
					g.doors[p] = {"open": true, "hp": door_hp, "max_hp": door_hp}
				_: g.tiles[p] = {"kind": "floor", "h": 0}
	return g

func in_bounds(p: Vector2i) -> bool:
	return tiles.has(p)

func kind(p: Vector2i) -> String:
	return tiles[p].kind if tiles.has(p) else "wall"

func height_at(p: Vector2i) -> int:
	return tiles[p].h if tiles.has(p) else 0

func is_door(p: Vector2i) -> bool:
	return doors.has(p)

func door_closed(p: Vector2i) -> bool:
	return doors.has(p) and not doors[p].open

## Terrain-only walkability (units are checked by the caller).
func walkable(p: Vector2i) -> bool:
	var k := kind(p)
	if k == "wall" or k == "cover":
		return false
	if k == "door":
		return doors[p].open
	return true

func blocks_sight(p: Vector2i) -> bool:
	var k := kind(p)
	return k == "wall" or (k == "door" and not doors[p].open)

static func cheb(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))

## Diagonal steps may not cut wall corners.
func step_ok(from: Vector2i, to: Vector2i) -> bool:
	if not walkable(to):
		return false
	var d := to - from
	if d.x != 0 and d.y != 0:
		if not walkable(Vector2i(from.x + d.x, from.y)) or not walkable(Vector2i(from.x, from.y + d.y)):
			return false
	return true

## Line of sight by sampling the segment between tile centres.
func has_los(a: Vector2i, b: Vector2i) -> bool:
	var n := cheb(a, b) * 3
	if n == 0:
		return true
	var fa := Vector2(a) + Vector2(0.5, 0.5)
	var fb := Vector2(b) + Vector2(0.5, 0.5)
	for i in range(1, n):
		var t := float(i) / n
		var q := fa.lerp(fb, t)
		var cell := Vector2i(floori(q.x), floori(q.y))
		if cell == a or cell == b:
			continue
		if blocks_sight(cell):
			return false
	return true

## Half cover: a cover tile adjacent to the target on the attacker's side (bible 03 §6.4).
func has_half_cover(attacker: Vector2i, target: Vector2i) -> bool:
	var dir := Vector2(attacker - target).normalized()
	for d in DIRS8:
		var p: Vector2i = target + d
		if kind(p) == "cover" or kind(p) == "wall":
			if Vector2(d).normalized().dot(dir) > 0.6 and cheb(attacker, target) > 1:
				return true
	return false

## Breadth-first reach (Chebyshev moves, cost 1 per step). blocked: Dictionary of occupied tiles.
## pass_doors: treat closed doors as walkable (used by AI to path toward a door it will break).
func reachable(start: Vector2i, max_steps: int, blocked: Dictionary, pass_doors := false) -> Dictionary:
	var dist := {start: 0}
	var frontier := [start]
	while not frontier.is_empty():
		var nxt := []
		for p in frontier:
			if dist[p] >= max_steps:
				continue
			for d in DIRS8:
				var q: Vector2i = p + d
				if dist.has(q) or blocked.has(q):
					continue
				var ok := step_ok(p, q)
				if not ok and pass_doors and is_door(q):
					ok = true
				if not ok:
					continue
				dist[q] = dist[p] + 1
				nxt.append(q)
		frontier = nxt
	return dist

## Shortest path (list of tiles excluding start). Empty if unreachable.
func path(start: Vector2i, goal: Vector2i, blocked: Dictionary, pass_doors := false) -> Array:
	var prev := {start: start}
	var frontier := [start]
	while not frontier.is_empty():
		var nxt := []
		for p in frontier:
			if p == goal:
				break
			for d in DIRS8:
				var q: Vector2i = p + d
				if prev.has(q) or (blocked.has(q) and q != goal):
					continue
				var ok := step_ok(p, q)
				if not ok and pass_doors and is_door(q):
					ok = true
				if not ok:
					continue
				prev[q] = p
				nxt.append(q)
		frontier = nxt
		if prev.has(goal):
			break
	if not prev.has(goal):
		return []
	var out := []
	var c := goal
	while c != start:
		out.push_front(c)
		c = prev[c]
	return out
