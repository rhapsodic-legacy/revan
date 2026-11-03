## Utility AI (bible 03 §6.9). Uses exactly the same legal actions as the player.
## Drives enemies, and drives the party under Standing Orders (autoplay, bible 03 §10).
extends RefCounted

const Grid = preload("res://engine/grid.gd")
const Unit = preload("res://engine/unit.gd")

## Difficulty knob: how often the AI takes its best-scored plan (bible 03 §6.9).
const ACCURACY := {"story": 60.0, "seer": 85.0, "vors": 100.0}

## Plays the current unit's whole turn. Returns the action ids taken.
static func take_turn(c) -> Array:
	var u = c.current()
	var taken := []
	if u == null:
		return taken
	var plans: Array = _plans(c, u)
	plans.sort_custom(func(a, b): return a.score > b.score)
	var pick: Dictionary = plans[0] if not plans.is_empty() else {"move": null, "action": "", "score": 0}
	var acc: float = ACCURACY.get(c.difficulty, 85.0)
	if plans.size() > 1 and not c.rng.chance(acc) and plans[1].score > 0:
		pick = plans[1]
	if pick.move != null and pick.move != u.pos:
		var mid := "move:%d,%d" % [pick.move.x, pick.move.y]
		if c.act(mid).ok:
			taken.append(mid)
	if c.current_id != u.id:
		return taken
	if pick.action != "" and _legal(c, pick.action):
		c.act(pick.action)
		taken.append(pick.action)
	elif pick.action != "":
		# Plan interrupted (e.g. an attack of opportunity moved things); take the best action from here.
		var alt: Array = _plans(c, u, true)
		alt.sort_custom(func(a, b): return a.score > b.score)
		if not alt.is_empty() and alt[0].action != "" and alt[0].score > 0 and _legal(c, alt[0].action):
			c.act(alt[0].action)
			taken.append(alt[0].action)
	if c.current_id == u.id:
		c.act("end")
		taken.append("end")
	return taken

static func _legal(c, id: String) -> bool:
	for a in c.legal_actions():
		if a.id == id:
			return true
	return false

## Multi-source distance field from every hostile, through doors (closed doors cost extra).
static func _field(c, u) -> Dictionary:
	var dist := {}
	var frontier := []
	for h in c.hostiles_of(u):
		if h.is_object():
			continue
		dist[h.pos] = 0
		frontier.append(h.pos)
	while not frontier.is_empty():
		frontier.sort_custom(func(a, b): return dist[a] < dist[b])
		var p: Vector2i = frontier.pop_front()
		for d in Grid.DIRS8:
			var q: Vector2i = p + d
			if not c.grid.in_bounds(q):
				continue
			var cost := 1
			if c.grid.is_door(q) and c.grid.door_closed(q):
				cost = 8 if c.grid.doors[q].get("locked", false) else 3
			elif not c.grid.step_ok(p, q):
				continue
			var nd: int = dist[p] + cost
			if not dist.has(q) or nd < dist[q]:
				dist[q] = nd
				frontier.append(q)
	return dist

static func _plans(c, u, stay_only := false) -> Array:
	var plans := []
	var field := _field(c, u)
	var tiles := {u.pos: 0}
	if not stay_only and not c.turn.moved:
		tiles = c.grid.reachable(u.pos, u.move, c.occupied(u))
	var origin: Vector2i = u.pos
	var hostiles: Array = c.hostiles_of(u)
	for t in tiles.keys():
		u.pos = t
		var pos_score := _position_score(c, u, t, origin, hostiles, field)
		var best_action := ""
		var best := 0.0
		if not c.turn.acted:
			for cand in _actions_from(c, u, t, hostiles, field):
				if cand.score > best:
					best = cand.score
					best_action = cand.id
		plans.append({"move": t, "action": best_action, "score": best + pos_score})
	u.pos = origin
	return plans

static func _position_score(c, u, t: Vector2i, origin: Vector2i, hostiles: Array, field: Dictionary) -> float:
	var s := 0.0
	var ranged: bool = c.is_ranged(u) or u.weapon.get("aoe", false)
	# Approach: get closer to the fight (ranged units are happy at range).
	var fd: float = field.get(t, 99)
	if ranged:
		s -= absf(fd - 5.0) * 0.6
	else:
		s -= fd * 1.2
	# Danger: how many hostiles could reach this tile next turn.
	var danger := 0
	for h in hostiles:
		if h.can_act() and Grid.cheb(h.pos, t) <= h.move + c.reach(h):
			danger += 1
	var w := 2.5 if ranged else 0.8
	if u.role == "brute":
		w = 0.3
	s -= danger * w
	# Cover for shooters.
	if ranged and not hostiles.is_empty():
		var nearest = hostiles[0]
		for h in hostiles:
			if Grid.cheb(h.pos, t) < Grid.cheb(nearest.pos, t):
				nearest = h
		if c.grid.has_half_cover(nearest.pos, t):
			s += 5.0
	# Leaving melee reach provokes attacks of opportunity.
	if t != origin:
		for h in hostiles:
			if h.can_act() and h.reaction_available and not c.is_ranged(h) \
					and Grid.cheb(h.pos, origin) <= c.reach(h) and Grid.cheb(h.pos, t) > c.reach(h):
				s -= 9.0
	return s

static func _actions_from(c, u, t: Vector2i, hostiles: Array, field: Dictionary) -> Array:
	var out := []
	var aoe: bool = u.weapon.get("aoe", false)
	# Single-target attacks on hostiles and on revealed objects worth breaking.
	var targets := hostiles.duplicate()
	for o in c.units:
		if o.is_object() and o.is_targetable() and o.team != u.team and _object_value(c, u, o) > 0:
			targets.append(o)
	if not aoe:
		for h in targets:
			if not c.can_attack_from(u, h, t):
				continue
			var pv: Dictionary = c.preview_attack(u, h, t)
			var avg = (pv.min + pv.max) / 2.0
			var ev = pv.hit / 100.0 * avg * (1.0 + pv.crit / 200.0)
			var sc = ev
			if pv.reflected_by != "":
				sc = -avg
			elif h.is_object():
				sc = _object_value(c, u, h) * pv.hit / 100.0
			else:
				if avg >= h.hp:
					sc += 20.0 * pv.hit / 100.0
				if u.temperament == "opportunist":
					sc += (1.0 - float(h.hp) / h.max_hp) * 8.0
				if h.role == "leader":
					sc += 3.0
				if h.has_status("taunt"):
					sc += 25.0
			out.append({"id": "attack:%s" % h.id, "score": sc})
	else:
		var centers := {}
		for h in c.units:
			if h.is_targetable() and Grid.cheb(h.pos, t) >= 2 and Grid.cheb(h.pos, t) <= int(u.weapon.get("range", 8)) and c.grid.has_los(t, h.pos):
				centers[h.pos] = true
		for cpos in centers.keys():
			var pv2: Dictionary = c.preview_blast(u, cpos)
			var avg2 = (pv2.min + pv2.max) / 2.0
			var sc2 := 0.0
			for id in pv2.hits:
				var v = c.by_id[id]
				if v == u or v.team == u.team:
					sc2 -= avg2 * 1.6
				elif v.team == Unit.TEAM_CIVILIAN or v.protect:
					sc2 -= avg2 * 3.0
				elif c.hostile(u, v):
					sc2 += avg2 * (1.0 + (0.5 if avg2 >= v.hp else 0.0))
				elif v.is_object():
					sc2 += _object_value(c, u, v)
			out.append({"id": "cannon:%d,%d" % [cpos.x, cpos.y], "score": sc2})
	# Doors on the way to the enemy: open them, or break them if locked.
	var here: float = field.get(t, 99)
	for dp in c.grid.doors.keys():
		if Grid.cheb(dp, t) == 1 and c.grid.door_closed(dp) and field.get(dp, 99) < here:
			if c.grid.doors[dp].get("locked", false):
				out.append({"id": "break:%d,%d" % [dp.x, dp.y], "score": 4.0})
			else:
				out.append({"id": "door:%d,%d" % [dp.x, dp.y], "score": 5.0})
	# Support.
	if "mend" in u.abilities and u.focus >= c.MEND_COST:
		for a in c.units:
			if a.team == u.team and a.can_act() and a.hp < a.max_hp * 0.5 and Grid.cheb(a.pos, t) <= 5 and c.grid.has_los(t, a.pos):
				out.append({"id": "mend:%s" % a.id, "score": c.mend_amount(u) * (1.4 if u.role == "support" else 1.0)})
	for a in c.units:
		if a.team == u.team and a.downed_turns >= 0 and not a.out and Grid.cheb(a.pos, t) == 1:
			out.append({"id": "revive:%s" % a.id, "score": 40.0})
	if "mend" in u.abilities and u.focus >= c.MEND_COST:
		for a in c.units:
			if a.team == u.team and a.downed_turns >= 0 and not a.out and Grid.cheb(a.pos, t) <= 5 and c.grid.has_los(t, a.pos):
				out.append({"id": "mend:%s" % a.id, "score": 45.0 + a.downed_limit - a.downed_turns})
	# Search once, early, with whoever sees best.
	if u.team == Unit.TEAM_PARTY and c.insights.any(func(i): return not i.found) and u.attrs.perception >= 14:
		out.append({"id": "search", "score": 14.0})
	return out

## Worth of destroying an object: disabling an enemy Deflector, or an explosive near enemies.
static func _object_value(c, u, o) -> float:
	var v := 0.0
	if o.on_destroy.has("disable_deflector"):
		var carrier = c.by_id.get(o.on_destroy["disable_deflector"])
		if carrier != null and carrier.deflector and c.hostile(u, carrier):
			v += 22.0
	if o.on_destroy.has("explode"):
		for x in c.units:
			if x.is_active() and not x.is_object() and Grid.cheb(x.pos, o.pos) <= 1:
				v += 12.0 if c.hostile(u, x) else -18.0
	if o.protect:
		v -= 50.0
	return v

## Runs a whole fight with AI on both sides. Returns the outcome.
static func autoplay(c, max_steps := 600) -> String:
	if c.current_id == "" and c.outcome == "":
		c.start()
	var steps := 0
	while c.outcome == "" and steps < max_steps:
		take_turn(c)
		steps += 1
	return c.outcome if c.outcome != "" else "draw"
