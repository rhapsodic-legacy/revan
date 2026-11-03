## Combat rules: "Live Ground" (bible 03 §6). Headless, deterministic, no nodes.
## Players, the built-in AI and external agents all drive it through legal_actions() and act().
extends RefCounted

const Unit = preload("res://engine/unit.gd")
const Grid = preload("res://engine/grid.gd")
const Rng = preload("res://engine/rng.gd")

const W_LIGHT := 0.8
const W_NORMAL := 1.0
const W_HEAVY := 1.3
const W_HOLD := 0.25
const DEFLECT_RADIUS := 2
const MEND_COST := 6
const MEDKIT_HEAL := 35
const MEDKIT_RANGE := 2
const PUSH_COST := 5
const PASS_COOLDOWN := 3

var arena_id := ""
var arena_name := ""
var objective := ""
var grid
var units: Array = []
var by_id := {}
var rng
var narration: Array = []
var time := 0.0
var next_tick := {}
var first_mover := ""            # scripted: this unit takes the first turn (e.g. a dialogue reward)
var current_id := ""
var bonus_turn := false
var turn := {}
var insights: Array = []
var outcome := ""
var fail_on_collateral := false
var collateral_lost: Array = []
var fallen: Array = []              # side characters whose arc ended (permanent)
var props: Array = []               # interactables: door panels, droppable racks...
var events: Array = []              # structured event stream (barks, flags, ratings)
var difficulty := "seer"
var turns_taken := 0
var max_turns := 400

# ------------------------------------------------------------------ setup

static func from_arena(data: Dictionary, seed_value: int = 1) -> RefCounted:
	var c = load("res://engine/combat.gd").new()
	c.rng = Rng.new(seed_value)
	c.arena_id = data.get("id", "arena")
	c.arena_name = data.get("name", c.arena_id)
	c.objective = data.get("objective", "Defeat all enemies.")
	c.fail_on_collateral = bool(data.get("fail_on_collateral", false))
	c.grid = Grid.from_rows(data["map"], int(data.get("door_hp", 60)))
	for ld in data.get("locked_doors", []):
		var p := Vector2i(int(ld[0]), int(ld[1]))
		if c.grid.doors.has(p):
			c.grid.doors[p]["locked"] = true
	for ud in data["units"]:
		c.add_unit(Unit.from_dict(ud))
	for hd in data.get("heavy_doors", []):
		var hp := Vector2i(int(hd[0]), int(hd[1]))
		if c.grid.doors.has(hp):
			c.grid.doors[hp]["heavy"] = true
	for pr in data.get("props", []):
		var prop: Dictionary = pr.duplicate(true)
		prop["used"] = false
		c.props.append(prop)
	for ins in data.get("insights", []):
		var i: Dictionary = ins.duplicate(true)
		i["found"] = false
		c.insights.append(i)
	c._apply_heights()
	return c

func add_unit(u) -> void:
	units.append(u)
	by_id[u.id] = u

func _apply_heights() -> void:
	for u in units:
		u.height_bonus = grid.height_at(u.pos)

func start() -> void:
	for u in units:
		if u.can_act():
			next_tick[u.id] = 1000.0 / u.speed
	if first_mover != "" and next_tick.has(first_mover):
		next_tick[first_mover] = 0.0
		say("%s is ready for them: acts first." % by_id[first_mover].name)
	say("Combat begins: %s. Objective: %s" % [arena_name, objective])
	_advance()

# ------------------------------------------------------------------ queries

func current():
	return by_id.get(current_id)

func hostile(a, b) -> bool:
	var ta: String = a.team
	var tb: String = b.team
	if ta == tb:
		return false
	if ta == Unit.TEAM_ENEMY:
		return tb == Unit.TEAM_PARTY
	if ta == Unit.TEAM_PARTY:
		return tb == Unit.TEAM_ENEMY
	return false

func unit_at(p: Vector2i):
	for u in units:
		if u.is_active() and u.pos == p and not _attached(u):
			return u
	return null

func _attached(u) -> bool:
	return u.is_object() and u.on_destroy.has("attached_to")

## Objects attached to a carrier (e.g. a Deflector backpack) ride along with it.
func _sync_attached() -> void:
	for u in units:
		if _attached(u):
			var c = by_id.get(u.on_destroy["attached_to"])
			if c != null:
				u.pos = c.pos
				if not c.is_active():
					u.dead = true

func occupied(except = null) -> Dictionary:
	var d := {}
	for u in units:
		if u == except or not u.is_active() or _attached(u):
			continue
		d[u.pos] = true
	return d

func hostiles_of(u) -> Array:
	return units.filter(func(o): return o.is_targetable() and o.downed_turns < 0 and hostile(u, o) and not ignored_by(u, o))

## Taz's "Just Some Punk": enemies ignore an unnoticed unit until it does something threatening.
func ignored_by(viewer, o) -> bool:
	return viewer.team == Unit.TEAM_ENEMY and o.has_status("unnoticed")

func _reveal(u) -> void:
	if u.has_status("unnoticed"):
		u.statuses.erase("unnoticed")
		say("%s stops pretending to be just some punk. Now they notice." % u.name)

func allies_of(u) -> Array:
	return units.filter(func(o): return o != u and o.is_active() and o.team == u.team)

func say(line: String) -> void:
	narration.append(line)

func emit(type: String, data := {}) -> void:
	var e := data.duplicate()
	e["type"] = type
	e["round"] = rounds_elapsed()
	events.append(e)

## Combat rounds elapsed, on the timeline's clock (a Speed-100 unit acts once per round).
func rounds_elapsed() -> int:
	return int(time / 10.0)

func insight_found(id: String) -> bool:
	for i in insights:
		if i.id == id:
			return i.found
	return false

func _prop_pos(pr) -> Vector2i:
	return Vector2i(int(pr.pos[0]), int(pr.pos[1]))

# ------------------------------------------------------------------ turn flow

func _advance() -> void:
	_check_outcome()
	if outcome != "":
		current_id = ""
		return
	var best_id := ""
	var best_t := INF
	for u in units:
		if not next_tick.has(u.id) or u.dead or u.out:
			continue
		var t: float = next_tick[u.id]
		if t < best_t or (is_equal_approx(t, best_t) and u.speed > by_id[best_id].speed):
			best_t = t
			best_id = u.id
	if best_id == "":
		outcome = "defeat"
		return
	time = best_t
	current_id = best_id
	bonus_turn = false
	_begin_turn(by_id[best_id])

func _begin_turn(u) -> void:
	turns_taken += 1
	turn = {"moved": false, "acted": false, "weight": W_NORMAL}
	u.reaction_available = true
	u.statuses.erase("off_guard")
	u.focus = minf(u.max_focus, u.focus + u.focus_regen())
	for k in u.cooldowns.keys():
		u.cooldowns[k] = maxi(0, u.cooldowns[k] - 1)
	if u.downed_turns >= 0:
		u.downed_turns -= 1
		if u.downed_turns < 0:
			u.out = true
			u.dead = true
			if u.essential:
				say("%s dies." % u.name)
			else:
				fallen.append(u.id)
				say("%s dies. Their story ends here." % u.name)
		else:
			say("%s is Downed (%d turn(s) left to revive)." % [u.name, u.downed_turns + 1])
		_finish_turn(W_NORMAL)
		return
	if "combat_drugs" in u.abilities and rng.chance(u.drug_chance):
		turn["extra"] = 1
		say("%s's combat drugs kick in: an extra action this turn." % u.name)
	if u.has_status("staggered"):
		u.statuses.erase("staggered")
		say("%s is Staggered and loses the turn." % u.name)
		_finish_turn(W_NORMAL)
		return
	if turns_taken > max_turns:
		outcome = "draw"

func _finish_turn(weight: float) -> void:
	var u = current()
	if u == null:
		return
	if not bonus_turn:
		next_tick[u.id] = time + (1000.0 / u.speed) * weight
	for s in u.statuses.keys():
		if s == "staggered":
			continue
		if u.statuses[s] > 0:
			u.statuses[s] -= 1
			if u.statuses[s] == 0:
				u.statuses.erase(s)
	_advance()

func _check_outcome() -> void:
	if outcome != "":
		return
	var enemies_left := units.filter(func(o): return o.team == Unit.TEAM_ENEMY and o.is_active())
	var party_up := units.filter(func(o): return o.team == Unit.TEAM_PARTY and o.can_act())
	var party_alive := units.filter(func(o): return o.team == Unit.TEAM_PARTY and o.is_active())
	for u in units:
		if u.essential and (u.out or u.dead):
			outcome = "defeat"
			say("%s has fallen. Game over." % u.name)
			return
	if fail_on_collateral and not collateral_lost.is_empty():
		outcome = "defeat"
		say("Collateral lost: %s. The fight is lost." % ", ".join(collateral_lost))
		return
	if enemies_left.is_empty():
		outcome = "victory"
		say("Victory.")
	elif party_up.is_empty():
		outcome = "defeat"
		say("The party has fallen.")

# ------------------------------------------------------------------ combat math

## front / flank / back of target relative to an attacker standing at from_pos.
func relation(target, from_pos: Vector2i) -> String:
	if target.is_object() or target.team == Unit.TEAM_CIVILIAN:
		return "front"
	var to_att := Vector2(from_pos - target.pos).normalized()
	var f := Vector2(target.facing).normalized()
	var d := f.dot(to_att)
	if d >= 0.5:
		return "front"
	if d <= -0.5:
		return "back"
	return "flank"

func _flanked(att, target, from_pos: Vector2i) -> bool:
	var v = from_pos - target.pos
	var opposite = target.pos - Vector2i(signi(v.x), signi(v.y))
	var o = unit_at(opposite)
	return o != null and o != att and o.team == att.team and o.can_act()

func is_ranged(u) -> bool:
	return u.weapon.get("kind", "melee") == "ranged"

func reach(u) -> int:
	return int(u.weapon.get("reach", 1)) if not is_ranged(u) else int(u.weapon.get("range", 8))

## Returns the deflector carrier that would reflect a shot from att aimed at p, or null.
func reflector_for(att, p: Vector2i):
	for o in units:
		if o.is_active() and o.deflector and o.team != att.team and o.team != Unit.TEAM_OBJECT \
				and Grid.cheb(o.pos, p) <= DEFLECT_RADIUS:
			return o
	return null

func can_attack_from(att, target, from_pos: Vector2i) -> bool:
	var dist := Grid.cheb(from_pos, target.pos)
	if is_ranged(att):
		var rng_bonus := 2 if grid.height_at(from_pos) > grid.height_at(target.pos) else 0
		return dist <= int(att.weapon.get("range", 8)) + rng_bonus and grid.has_los(from_pos, target.pos) and dist >= 1
	return dist <= int(att.weapon.get("reach", 1)) and dist >= 1 and (dist == 1 or grid.has_los(from_pos, target.pos))

func preview_attack(att, target, from_pos: Vector2i = Vector2i(-999, -999)) -> Dictionary:
	if from_pos.x == -999:
		from_pos = att.pos
	var rel := relation(target, from_pos)
	var hit: float = float(att.weapon.get("accuracy", 80))
	hit += (att.attrs.grace - 10) * 1.5
	var is_obj: bool = target.is_object()
	if not is_obj:
		hit -= (target.attrs.grace - 10) * 1.0
	if rel == "flank":
		hit += 20
	elif rel == "back":
		hit += 40
	var high = grid.height_at(from_pos) > grid.height_at(target.pos)
	if high:
		hit += 15
	if not is_ranged(att) and _flanked(att, target, from_pos):
		hit += 10
	var cover = is_ranged(att) and grid.has_half_cover(from_pos, target.pos)
	if cover:
		hit -= 25
	if is_obj:
		hit = 95
	hit = clampf(hit, 5, 95)
	var stat: int = att.attrs.grace if is_ranged(att) else att.attrs.might
	var bonus := int((stat - 10) * 0.5)
	var mult := 1.0
	if rel == "flank":
		mult *= 1.15
	elif rel == "back":
		mult *= 1.30
	if high:
		mult *= 1.10
	var def_pct: int = target.defense
	if target.has_status("off_guard"):
		def_pct = maxi(0, def_pct - 25)
	mult *= (100 - def_pct) / 100.0
	if target.has_status("staggered"):
		mult *= 1.5
	var lo := maxi(1, int((int(att.weapon.get("min", 5)) + bonus) * mult))
	var hi := maxi(lo, int((int(att.weapon.get("max", 9)) + bonus) * mult))
	var crit := clampf(5 + (att.attrs.perception - 10) * 0.5 + (15 if rel == "back" else 0), 0, 60)
	var reflected = null
	if (is_ranged(att) or att.weapon.get("aoe", false)) and not target.on_destroy.has("disable_deflector"):
		reflected = reflector_for(att, target.pos)
	return {"hit": int(hit), "min": lo, "max": hi, "crit": int(crit), "relation": rel,
		"cover": cover, "high_ground": high,
		"reflected_by": reflected.id if reflected != null else ""}

func _roll_damage(p: Dictionary) -> Dictionary:
	var dmg = rng.randi_range(p.min, p.max)
	var crit: bool = rng.chance(p.crit)
	if crit:
		dmg = int(dmg * 1.5)
	return {"dmg": dmg, "crit": crit}

func deal(target, amount: int, poise_dmg: int, source_name: String) -> void:
	if not target.is_active():
		return
	if target.shield > 0:
		var absorbed := mini(target.shield, amount)
		target.shield -= absorbed
		amount -= absorbed
		if target.shield == 0 and absorbed > 0:
			say("%s's shield breaks." % target.name)
	target.hp -= amount
	if amount > 0 and not target.is_object():
		emit("hit", {"target": target.id, "amount": amount, "by": source_name})
	if amount > 0:
		target.statuses.erase("unnoticed")
	if not target.is_object() and target.team != Unit.TEAM_CIVILIAN:
		target.poise -= poise_dmg
		if target.poise <= 0 and target.hp > 0:
			target.poise = target.max_poise
			target.add_status("staggered", -1)
			say("%s is Staggered." % target.name)
	if target.hp <= 0:
		target.hp = 0
		_on_zero(target, source_name)

func _on_zero(t, source_name: String) -> void:
	emit("down", {"target": t.id, "team": t.team, "by": source_name})
	if t.team == Unit.TEAM_PARTY:
		if t.downed_turns < 0:
			t.downed_turns = t.downed_limit
			t.statuses.clear()
			say("%s is Downed by %s." % [t.name, source_name])
		return
	t.dead = true
	if t.team == Unit.TEAM_CIVILIAN or t.protect:
		collateral_lost.append(t.name)
		say("%s is lost." % t.name)
	elif t.is_object():
		say("%s is destroyed." % t.name)
	else:
		say("%s falls." % t.name)
	if t.on_destroy.has("disable_deflector"):
		var carrier = by_id.get(t.on_destroy["disable_deflector"])
		if carrier != null:
			carrier.deflector = false
			say("%s's Deflector sputters out." % carrier.name)
	if t.on_destroy.has("explode"):
		say("%s explodes!" % t.name)
		_blast(t.pos, int(t.on_destroy["explode"]), int(t.on_destroy["explode"]) + 6, t.name)

func _blast(center: Vector2i, lo: int, hi: int, source_name: String) -> Array:
	_sync_attached()
	var hit_names := []
	for u in units.duplicate():
		if not u.is_active() or (u.hidden and not _attached(u)):
			continue
		if Grid.cheb(u.pos, center) <= 1:
			var d = rng.randi_range(lo, hi)
			hit_names.append("%s (%d)" % [u.name, d])
			deal(u, d, d / 2, source_name)
	for dp in grid.doors.keys():
		if Grid.cheb(dp, center) <= 1:
			_damage_door(dp, rng.randi_range(lo, hi))
	return hit_names

func _damage_door(p: Vector2i, dmg: int) -> void:
	if not grid.doors.has(p):
		return
	grid.doors[p].hp -= dmg
	if grid.doors[p].hp <= 0:
		grid.doors.erase(p)
		grid.tiles[p] = {"kind": "floor", "h": 0}
		say("The door at (%d,%d) is smashed open." % [p.x, p.y])
	else:
		say("The door at (%d,%d) takes %d (%d HP left)." % [p.x, p.y, dmg, grid.doors[p].hp])

# ------------------------------------------------------------------ legal actions

func legal_actions() -> Array:
	var out := []
	var u = current()
	if u == null or outcome != "":
		return out
	_sync_attached()
	var occ := occupied(u)
	if not turn.moved:
		var reach_map: Dictionary = grid.reachable(u.pos, u.move, occ)
		for p in reach_map.keys():
			if p != u.pos:
				out.append({"id": "move:%d,%d" % [p.x, p.y], "type": "move", "to": [p.x, p.y], "cost": reach_map[p]})
		if not turn.acted:
			var dash_map: Dictionary = grid.reachable(u.pos, u.move * 2, occ)
			for p in dash_map.keys():
				if dash_map[p] > u.move:
					out.append({"id": "dash:%d,%d" % [p.x, p.y], "type": "dash", "to": [p.x, p.y], "cost": dash_map[p]})
	if not turn.acted:
		for t in units:
			if t == u or not t.is_targetable() or t.team == u.team or ignored_by(u, t):
				continue
			if t.team == Unit.TEAM_CIVILIAN:
				continue
			if u.weapon.get("aoe", false):
				continue
			if can_attack_from(u, t, u.pos):
				var pv := preview_attack(u, t)
				out.append({"id": "attack:%s" % t.id, "type": "attack", "target": t.id, "preview": pv})
		if u.weapon.get("aoe", false):
			var centers := {}
			for t in units:
				if t.is_targetable() and t != u and Grid.cheb(t.pos, u.pos) <= int(u.weapon.get("range", 8)) \
						and grid.has_los(u.pos, t.pos) and Grid.cheb(t.pos, u.pos) >= 2:
					centers[t.pos] = true
			for c in centers.keys():
				out.append({"id": "cannon:%d,%d" % [c.x, c.y], "type": "cannon", "center": [c.x, c.y], "preview": preview_blast(u, c)})
		for dp in grid.doors.keys():
			var dist := Grid.cheb(dp, u.pos)
			if not grid.doors[dp].open and ((not is_ranged(u) and dist == 1) or (is_ranged(u) and dist <= int(u.weapon.get("range", 8)) and grid.has_los(u.pos, dp))):
				out.append({"id": "break:%d,%d" % [dp.x, dp.y], "type": "break_door", "door": [dp.x, dp.y], "door_hp": grid.doors[dp].hp})
			if dist == 1 and unit_at(dp) == null:
				var is_open: bool = grid.doors[dp].open
				var locked: bool = grid.doors[dp].get("locked", false)
				if is_open or not locked:
					out.append({"id": "door:%d,%d" % [dp.x, dp.y], "type": "door", "door": [dp.x, dp.y], "will": "close" if is_open else "open"})
				if not is_open and not locked and "lock" in u.abilities:
					out.append({"id": "lock:%d,%d" % [dp.x, dp.y], "type": "lock", "door": [dp.x, dp.y]})
		if "shove" in u.abilities:
			for t in units:
				if t != u and t.is_targetable() and not t.is_object() and Grid.cheb(t.pos, u.pos) == 1:
					out.append({"id": "shove:%s" % t.id, "type": "shove", "target": t.id, "chance": shove_chance(u, t)})
		if "push" in u.abilities and u.focus >= PUSH_COST:
			for t in hostiles_of(u):
				if not t.is_object() and Grid.cheb(t.pos, u.pos) <= 5 and grid.has_los(u.pos, t.pos):
					out.append({"id": "push:%s" % t.id, "type": "push", "target": t.id, "chance": shove_chance(u, t, true), "focus": PUSH_COST})
		if "mend" in u.abilities and u.focus >= MEND_COST:
			for t in units:
				if t.team == u.team and t.is_active() and (t.downed_turns >= 0 or (t.can_act() and t.hp < t.max_hp)) and Grid.cheb(t.pos, u.pos) <= 5 and grid.has_los(u.pos, t.pos):
					out.append({"id": "mend:%s" % t.id, "type": "mend", "target": t.id, "heal": mend_amount(u), "focus": MEND_COST})
		if "medkit" in u.abilities and u.charges.get("medkit", 0) > 0:
			for t in units:
				if t.team == u.team and t.is_active() and (t.downed_turns >= 0 or (t.can_act() and t.hp < t.max_hp)) and Grid.cheb(t.pos, u.pos) <= MEDKIT_RANGE and grid.has_los(u.pos, t.pos):
					out.append({"id": "medkit:%s" % t.id, "type": "medkit", "target": t.id, "heal": MEDKIT_HEAL, "left": u.charges.medkit})
		for t in units:
			if t.team == u.team and t.downed_turns >= 0 and not t.out and Grid.cheb(t.pos, u.pos) == 1:
				out.append({"id": "revive:%s" % t.id, "type": "revive", "target": t.id})
		if insights.any(func(i): return not i.found):
			out.append({"id": "search", "type": "search", "perception": u.attrs.perception})
		for pr in props:
			if pr.used or Grid.cheb(_prop_pos(pr), u.pos) > 1:
				continue
			if pr.has("requires") and not insight_found(pr.requires):
				continue
			if u.team != Unit.TEAM_PARTY and pr.get("party_only", true):
				continue
			var entry := {"id": "use:%s" % pr.id, "type": "use", "prop": pr.id, "name": pr.get("name", pr.id), "kind": pr.kind}
			if pr.kind == "door_panel":
				var dpp := Vector2i(int(pr.door[0]), int(pr.door[1]))
				if not grid.doors.has(dpp) or unit_at(dpp) != null:
					continue
				entry["will"] = "close" if grid.doors[dpp].open else "open"
			out.append(entry)
		if "taunt" in u.abilities and u.cooldowns.get("taunt", 0) == 0:
			out.append({"id": "taunt", "type": "taunt"})
		if "raise_shield" in u.abilities and u.cooldowns.get("raise_shield", 0) == 0:
			out.append({"id": "shield", "type": "shield", "amount": int(u.shield_power)})
		if "stun_grenade" in u.abilities and u.charges.get("stun_grenade", 0) > 0 and not "stun_grenade" in u.locked:
			var gc := {}
			for t in hostiles_of(u):
				if Grid.cheb(t.pos, u.pos) <= 6 and grid.has_los(u.pos, t.pos):
					gc[t.pos] = true
			for g in gc.keys():
				var who := []
				for t in units:
					if t.is_active() and not t.is_object() and not t.hidden and Grid.cheb(t.pos, g) <= 1:
						who.append(t.id)
				out.append({"id": "grenade:%d,%d" % [g.x, g.y], "type": "grenade", "center": [g.x, g.y], "hits": who})
		if "pass_turn" in u.abilities and not turn.moved and u.cooldowns.get("pass_turn", 0) == 0 and not bonus_turn:
			for t in allies_of(u):
				if t.can_act():
					out.append({"id": "pass:%s" % t.id, "type": "pass_turn", "target": t.id})
	if not turn.moved and not turn.acted and not bonus_turn:
		out.append({"id": "hold", "type": "hold"})
	out.append({"id": "end", "type": "end"})
	return out

func preview_blast(att, c: Vector2i) -> Dictionary:
	var reflected = reflector_for(att, c)
	var center: Vector2i = att.pos if reflected != null else c
	var hits := []
	for t in units:
		if t.is_active() and not t.hidden and Grid.cheb(t.pos, center) <= 1:
			hits.append(t.id)
	return {"min": int(att.weapon.get("min", 8)), "max": int(att.weapon.get("max", 14)),
		"hits": hits, "reflected_by": reflected.id if reflected != null else ""}

func shove_chance(att, t, weave := false) -> int:
	if t.team == Unit.TEAM_CIVILIAN:
		return 100
	var power: int = att.attrs.eternity if weave else att.attrs.might
	return clampi(55 + (power - t.attrs.might) * 3 - int(t.poise / 4.0) + 5, 10, 95)

func mend_amount(u) -> int:
	return 10 + u.attrs.eternity

# ------------------------------------------------------------------ acting

## Performs one legal action. Returns {"ok", "error", "log"} where log is the narration delta.
func act(action_id: String) -> Dictionary:
	var before := narration.size()
	var legal := legal_actions()
	var found = null
	for a in legal:
		if a.id == action_id:
			found = a
			break
	if found == null:
		return {"ok": false, "error": "Illegal action '%s'." % action_id, "log": []}
	var u = current()
	if not found.type in ["move", "dash", "end", "hold", "door", "search"]:
		_reveal(u)
	match found.type:
		"move":
			_move_along(u, Vector2i(found.to[0], found.to[1]))
			turn.moved = true
		"dash":
			_move_along(u, Vector2i(found.to[0], found.to[1]))
			turn.moved = true
			turn.acted = true
			_end_current(W_NORMAL)
		"attack":
			_do_attack(u, by_id[found.target])
			_acted(W_NORMAL)
		"cannon":
			emit("cannon", {"by": u.id})
			_do_cannon(u, Vector2i(found.center[0], found.center[1]))
			_acted(W_HEAVY)
		"break_door":
			var dp := Vector2i(found.door[0], found.door[1])
			var dmg = rng.randi_range(int(u.weapon.get("min", 5)), int(u.weapon.get("max", 9)))
			say("%s hammers the door." % u.name)
			_damage_door(dp, dmg)
			_acted(W_NORMAL)
		"door":
			var dp2 := Vector2i(found.door[0], found.door[1])
			_toggle_door(dp2, u.name)
			if grid.doors.has(dp2) and grid.doors[dp2].get("heavy", false):
				say("Hauling the heavy door takes %s's whole turn." % u.name)
				turn.moved = true
				_acted(W_NORMAL)
				if current() == u and outcome == "":
					_end_current(W_NORMAL)
			else:
				_acted(W_LIGHT)
		"use":
			_use_prop(u, found.prop)
			_acted(W_NORMAL)
		"taunt":
			u.add_status("taunt", 2)
			u.cooldowns["taunt"] = 3
			say("%s bellows a challenge. Enemies can't ignore him." % u.name)
			emit("taunt", {"by": u.id})
			_acted(W_LIGHT)
		"shield":
			u.shield = maxi(u.shield, int(u.shield_power))
			u.cooldowns["raise_shield"] = 4
			say("%s raises a personal shield (%d)." % [u.name, u.shield])
			_acted(W_NORMAL)
		"grenade":
			u.charges["stun_grenade"] -= 1
			var gp := Vector2i(found.center[0], found.center[1])
			say("%s lobs a Stun Grenade at (%d,%d)!" % [u.name, gp.x, gp.y])
			for t in units.duplicate():
				if t.is_active() and not t.is_object() and not t.hidden and Grid.cheb(t.pos, gp) <= 1:
					t.add_status("staggered", -1)
					say("%s is stunned." % t.name)
					deal(t, 5, 0, u.name)
			emit("grenade", {"by": u.id})
			_acted(W_NORMAL)
		"lock":
			var dp3 := Vector2i(found.door[0], found.door[1])
			grid.doors[dp3]["locked"] = true
			say("%s locks the door at (%d,%d). Anyone behind it will have to break it." % [u.name, dp3.x, dp3.y])
			_acted(W_LIGHT)
		"shove":
			_do_shove(u, by_id[found.target], false)
			_acted(W_NORMAL)
		"push":
			u.focus -= PUSH_COST
			_do_shove(u, by_id[found.target], true)
			_acted(W_NORMAL)
		"mend":
			u.focus -= MEND_COST
			var t = by_id[found.target]
			var h := mini(mend_amount(u), t.max_hp - t.hp)
			t.hp += h
			say("%s Mends %s for %d." % [u.name, t.name, h])
			if t.downed_turns >= 0:
				t.downed_turns = -1
				say("%s is back on their feet." % t.name)
			_acted(W_NORMAL)
		"medkit":
			u.charges["medkit"] -= 1
			var mt = by_id[found.target]
			var mh := mini(MEDKIT_HEAL, mt.max_hp - mt.hp)
			mt.hp += mh
			say("%s patches up %s with her Medkit: +%d (%d left)." % [u.name, mt.name, mh, u.charges.medkit])
			if mt.downed_turns >= 0:
				mt.downed_turns = -1
				say("%s is back on their feet." % mt.name)
			emit("use", {"by": u.id, "what": "medkit"})
			_acted(W_NORMAL)
		"revive":
			var r = by_id[found.target]
			r.downed_turns = -1
			r.hp = maxi(1, r.max_hp / 4)
			say("%s hauls %s back to their feet." % [u.name, r.name])
			_acted(W_NORMAL)
		"search":
			_do_search(u)
			_acted(W_LIGHT)
		"pass_turn":
			var ally = by_id[found.target]
			u.cooldowns["pass_turn"] = PASS_COOLDOWN + 1
			say("%s passes her turn to %s." % [u.name, ally.name] if u.id == "deena" else "%s passes the turn to %s." % [u.name, ally.name])
			next_tick[u.id] = time + (1000.0 / u.speed) * W_LIGHT
			current_id = ally.id
			bonus_turn = true
			turn = {"moved": false, "acted": false, "weight": W_NORMAL}
		"hold":
			say("%s holds." % u.name)
			_end_current(W_HOLD)
		"end":
			_end_current(turn.weight)
	return {"ok": true, "error": "", "log": narration.slice(before)}

func _acted(w: float) -> void:
	turn.acted = true
	turn.weight = w
	_check_outcome()
	if outcome == "" and turn.get("extra", 0) > 0 and current() != null and current().can_act():
		turn.extra -= 1
		turn.acted = false
		return
	if outcome != "":
		current_id = ""
		return
	var u = current()
	if u != null and not u.can_act():
		_end_current(w)

func _end_current(w: float) -> void:
	if outcome != "":
		return
	_finish_turn(w)

func _move_along(u, goal: Vector2i) -> void:
	var p: Array = grid.path(u.pos, goal, occupied(u))
	var start = u.pos
	for step in p:
		var prev: Vector2i = u.pos
		_opportunity_attacks(u, prev, step)
		if not u.can_act():
			break
		u.facing = Vector2i(signi(step.x - prev.x), signi(step.y - prev.y))
		u.pos = step
	u.height_bonus = grid.height_at(u.pos)
	say("%s moves from (%d,%d) to (%d,%d)." % [u.name, start.x, start.y, u.pos.x, u.pos.y])

func _opportunity_attacks(mover, from: Vector2i, to: Vector2i) -> void:
	for e in units:
		if not e.can_act() or not hostile(e, mover) or ignored_by(e, mover) or not e.reaction_available or e.has_status("off_guard"):
			continue
		if is_ranged(e) or e.weapon.get("aoe", false):
			continue
		var r := reach(e)
		if Grid.cheb(e.pos, from) <= r and Grid.cheb(e.pos, to) > r:
			e.reaction_available = false
			say("%s takes an attack of opportunity." % e.name)
			_do_attack(e, mover)
			if not mover.can_act():
				return

func _do_attack(u, t) -> void:
	var pv := preview_attack(u, t)
	var victim = t
	if pv.reflected_by != "":
		victim = u
		say("%s's shot hits %s's Deflector and rebounds!" % [u.name, by_id[pv.reflected_by].name])
		var r := _roll_damage(pv)
		deal(u, r.dmg, 0, by_id[pv.reflected_by].name)
		say("%s is hit by their own shot for %d." % [u.name, r.dmg])
		return
	if not rng.chance(pv.hit):
		say("%s attacks %s and misses (%d%%)." % [u.name, t.name, pv.hit])
		_face(t, u.pos)
		return
	var r2 := _roll_damage(pv)
	var poise: int = r2.dmg / 2 if not is_ranged(u) else r2.dmg / 4
	var extra := ""
	if pv.relation != "front":
		extra += " from the %s" % pv.relation
	if r2.crit:
		extra += " (critical)"
	say("%s hits %s%s for %d." % [u.name, victim.name, extra, r2.dmg])
	deal(victim, r2.dmg, poise, u.name)
	if pv.relation == "back" and victim.deflector and victim.is_active():
		_crack_deflector(victim, u)
	_face(victim, u.pos)

func _crack_deflector(carrier, by) -> void:
	for o in units:
		if o.is_object() and o.on_destroy.get("attached_to", "") == carrier.id and o.is_active():
			o.hidden = false
			say("The hit from behind cracks %s's Deflector generator." % carrier.name)
			deal(o, o.hp, 0, by.name)
	if carrier.deflector:
		carrier.deflector = false
		say("%s's Deflector sputters out." % carrier.name)
	emit("deflector_down", {"carrier": carrier.id, "by": by.id})

func _toggle_door(dp: Vector2i, who: String) -> void:
	grid.doors[dp].open = not grid.doors[dp].open
	say("%s %s the door at (%d,%d)." % [who, "opens" if grid.doors[dp].open else "closes", dp.x, dp.y])
	emit("door", {"pos": [dp.x, dp.y], "open": grid.doors[dp].open})

func _use_prop(u, id: String) -> void:
	var pr = null
	for x in props:
		if x.id == id:
			pr = x
	if pr == null:
		return
	match pr.kind:
		"door_panel":
			var dp := Vector2i(int(pr.door[0]), int(pr.door[1]))
			say("%s slaps the emergency panel." % u.name)
			_toggle_door(dp, "The emergency battery")
		"drop":
			pr.used = true
			say("%s drops the %s!" % [u.name, pr.get("name", "load")])
			for tp in pr.tiles:
				var victim = unit_at(Vector2i(int(tp[0]), int(tp[1])))
				if victim != null and not victim.is_object():
					var d: int = rng.randi_range(int(pr.get("min", 15)), int(pr.get("max", 25)))
					say("It crashes onto %s for %d." % [victim.name, d])
					deal(victim, d, 0, pr.get("name", "load"))
					if victim.is_active():
						victim.add_status("staggered", -1)
						say("%s is Staggered." % victim.name)
	emit("use", {"prop": id, "by": u.id})

func _face(t, from: Vector2i) -> void:
	if t.is_object() or not t.is_active():
		return
	var d = from - t.pos
	if d != Vector2i.ZERO:
		t.facing = Vector2i(signi(d.x), signi(d.y))

func _do_cannon(u, c: Vector2i) -> void:
	var refl = reflector_for(u, c)
	var center := c
	if refl != null:
		center = u.pos
		say("%s's cannon blast slams into %s's Deflector and rebounds onto %s!" % [u.name, refl.name, u.name])
	else:
		say("%s fires the cannon at (%d,%d)." % [u.name, c.x, c.y])
	var hits := _blast(center, int(u.weapon.get("min", 8)), int(u.weapon.get("max", 14)), u.name)
	if not hits.is_empty():
		say("The blast hits: %s." % ", ".join(hits))

func _do_shove(u, t, weave: bool) -> void:
	var ch := shove_chance(u, t, weave)
	var verb := "Pushes" if weave else "Shoves"
	if not rng.chance(ch):
		say("%s tries to %s %s and fails (%d%%)." % [u.name, verb.to_lower().trim_suffix("s"), t.name, ch])
		return
	var d = t.pos - u.pos
	var dir := Vector2i(signi(d.x), signi(d.y))
	var dist := 3 if weave else 2
	var moved := 0
	for i in dist:
		var nxt: Vector2i = t.pos + dir
		if not grid.walkable(nxt) or unit_at(nxt) != null:
			say("%s %s %s into an obstacle." % [u.name, verb.to_lower(), t.name])
			deal(t, 8, 12, u.name)
			break
		t.pos = nxt
		moved += 1
	t.height_bonus = grid.height_at(t.pos)
	if t.team == Unit.TEAM_CIVILIAN:
		say("\"Get down! Move!\" %s gets %s out of the line of fire." % [u.name, t.name])
	elif moved > 0:
		say("%s %s %s back %d tile(s)." % [u.name, verb.to_lower(), t.name, moved])
	emit("shove", {"target": t.id, "by": u.id, "to": [t.pos.x, t.pos.y]})

func _do_search(u) -> void:
	var any := false
	for i in insights:
		if i.found:
			continue
		var roll: int = rng.randi_range(1, 20) + u.attrs.perception
		if roll >= int(i.get("dc", 20)):
			i.found = true
			any = true
			say("%s spots something: %s" % [u.name, i.get("text", "an Insight")])
			emit("insight", {"id": i.id, "by": u.id})
			if i.has("reveals"):
				var o = by_id.get(i.reveals)
				if o != null:
					o.hidden = false
	if not any:
		say("%s searches the area and finds nothing new." % u.name)

# ------------------------------------------------------------------ views

func timeline(n := 12) -> Array:
	var ticks := next_tick.duplicate()
	var out := []
	if current_id != "":
		out.append({"id": current_id, "name": by_id[current_id].name, "team": by_id[current_id].team, "now": true})
		if not bonus_turn:
			ticks[current_id] = time + 1000.0 / by_id[current_id].speed
	while out.size() < n:
		var best := ""
		var bt := INF
		for id in ticks.keys():
			var u = by_id[id]
			if u.dead or u.out:
				continue
			if ticks[id] < bt:
				bt = ticks[id]
				best = id
		if best == "":
			break
		out.append({"id": best, "name": by_id[best].name, "team": by_id[best].team})
		ticks[best] += 1000.0 / by_id[best].speed
	return out

func state() -> Dictionary:
	var party := []
	var enemies := []
	var others := []
	for u in units:
		if u.hidden:
			continue
		var d: Dictionary = u.to_dict()
		match u.team:
			Unit.TEAM_PARTY: party.append(d)
			Unit.TEAM_ENEMY: enemies.append(d)
			_: others.append(d)
	var doors := []
	for p in grid.doors.keys():
		doors.append({"pos": [p.x, p.y], "open": grid.doors[p].open, "locked": grid.doors[p].get("locked", false), "hp": grid.doors[p].hp})
	return {
		"mode": "combat" if outcome == "" else "result",
		"arena": {"id": arena_id, "name": arena_name, "objective": objective},
		"outcome": outcome,
		"current": current_id,
		"turn": turn,
		"party": party, "enemies": enemies, "others": others, "doors": doors,
		"insights": insights.filter(func(i): return i.found).map(func(i): return i.text),
		"props": props.filter(func(pr): return not pr.used and (not pr.has("requires") or insight_found(pr.requires))).map(func(pr): return {"id": pr.id, "name": pr.get("name", pr.id), "kind": pr.kind, "pos": pr.pos}),
		"round": rounds_elapsed(),
		"timeline": timeline(),
		"legalActions": legal_actions(),
		"log": narration.slice(maxi(0, narration.size() - 12)),
	}

## ASCII top-down of the combat grid (bible 03 §11.1 describeMap).
func describe_map() -> String:
	var lines := []
	var glyphs := {}
	for u in units:
		if u.is_active() and not u.hidden and not _attached(u):
			glyphs[u.pos] = u.name_short
	for y in grid.height:
		var row := ""
		for x in grid.width:
			var p := Vector2i(x, y)
			if glyphs.has(p):
				row += glyphs[p]
				continue
			match grid.kind(p):
				"wall": row += "#"
				"water": row += "~"
				"cover": row += "="
				"door": row += "/" if grid.doors[p].open else ("X" if grid.doors[p].get("locked", false) else "+")
				_: row += "^" if grid.height_at(p) > 0 else "."
		lines.append(row)
	lines.append("")
	for u in units:
		if u.is_active() and not u.hidden:
			var tag := "*" if u.id == current_id else " "
			lines.append("%s%s %s [%s] HP %d/%d at (%d,%d)%s" % [tag, u.name_short, u.name, u.team, u.hp, u.max_hp, u.pos.x, u.pos.y, " DOWNED" if u.downed_turns >= 0 else ""])
	return "\n".join(lines)

## Scripted control (tests, cutscene-driven fights): give unit `id` the turn right now.
func force_turn(id: String) -> void:
	current_id = id
	bonus_turn = true
	turn = {"moved": false, "acted": false, "weight": W_NORMAL}
	by_id[id].reaction_available = true
