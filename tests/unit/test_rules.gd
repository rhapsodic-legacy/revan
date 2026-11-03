extends "res://tests/unit/test_case.gd"

const Combat = preload("res://engine/combat.gd")
const Data = preload("res://engine/data.gd")
const AI = preload("res://engine/ai.gd")

func _arena(rows: Array, units: Array, extra := {}) -> RefCounted:
	var chars: Dictionary = Data.characters()
	var us := []
	for ud in units:
		var m: Dictionary = chars[ud["template"]].duplicate(true) if ud.has("template") else {}
		for k in ud.keys():
			m[k] = ud[k]
		us.append(m)
	var d := {"id": "t", "name": "t", "map": rows, "units": us}
	for k in extra.keys():
		d[k] = extra[k]
	var c = Combat.from_arena(d, 3)
	c.start()
	return c

func _ids(c) -> Array:
	return c.legal_actions().map(func(a): return a.id)

const OPEN := ["##########", "#........#", "#........#", "#........#", "#........#", "##########"]

func test_derived_stats_follow_bible_formulas() -> void:
	var c = _arena(OPEN, [{"template": "dust", "id": "dust", "pos": [1, 1]}, {"template": "thug", "id": "t1", "pos": [8, 4]}])
	var d = c.by_id["dust"]
	eq(d.max_hp, 40 + 12 * 6 + 3 * 8, "HP = 40 + Vigor*6 + Level*8")
	eq(d.max_poise, 20 + 12 * 2, "Poise = 20 + Vigor*2")
	eq(d.speed, 100.0 + 12 * 1.5 + 11, "Speed = 100 + Grace*1.5 + Perception")

func test_fastest_unit_acts_first() -> void:
	var c = _arena(OPEN, [{"template": "ksaabu", "id": "k", "pos": [1, 1]}, {"template": "deena", "id": "deena", "pos": [1, 3]},
		{"template": "thug", "id": "t1", "pos": [8, 4]}])
	eq(c.current_id, "deena", "Deena (fastest) opens the timeline")
	eq(c.timeline()[0].id, "deena", "timeline starts with current unit")

func test_same_seed_same_fight() -> void:
	var a = Data.new_combat("deflector", 42)
	var b = Data.new_combat("deflector", 42)
	AI.autoplay(a)
	AI.autoplay(b)
	eq(a.narration, b.narration, "deterministic with the same seed")

func test_closed_door_blocks_sight_and_movement() -> void:
	var rows := ["#######", "#..+..#", "#######"]
	var c = _arena(rows, [{"template": "deena", "id": "deena", "pos": [1, 1]}, {"template": "thug", "id": "t1", "pos": [5, 1]}])
	check(not c.grid.has_los(Vector2i(1, 1), Vector2i(5, 1)), "closed door blocks LOS")
	check(not ("attack:t1" in _ids(c)), "no shot through a closed door")
	check(not ("move:4,1" in _ids(c)), "can't walk through a closed door")
	check("break:3,1" in _ids(c), "a ranged unit can shoot the door")

func test_locked_door_must_be_broken() -> void:
	var rows := ["#######", "#..+..#", "#######"]
	var c = _arena(rows, [{"template": "deena", "id": "deena", "pos": [2, 1]}, {"template": "thug", "id": "t1", "pos": [4, 1]}])
	check("lock:3,1" in _ids(c), "Deena can lock an adjacent door")
	c.act("lock:3,1")
	c.force_turn("t1")
	check(not ("door:3,1" in _ids(c)), "a locked door can't simply be opened")
	check("break:3,1" in _ids(c), "but it can be broken")

func test_deflector_reflects_cannon() -> void:
	var c = _arena(OPEN, [{"template": "ksaabu", "id": "k", "pos": [1, 2], "shield": 0},
		{"template": "sergeant", "id": "sgt", "pos": [6, 2]}, {"template": "thug", "id": "t1", "pos": [7, 2]}])
	c.force_turn("k")
	var pv: Dictionary = c.legal_actions().filter(func(a): return a.id == "cannon:7,2")[0].preview
	eq(pv.reflected_by, "sgt", "preview warns the blast will be reflected")
	var hp_before: int = c.by_id["k"].hp
	c.act("cannon:7,2")
	check(c.by_id["k"].hp < hp_before, "K'saabu is hit by his own blast")
	eq(c.by_id["t1"].hp, c.by_id["t1"].max_hp, "the thug behind the Deflector is untouched")

func test_shooting_the_generator_kills_the_deflector() -> void:
	var units := [{"template": "deena", "id": "deena", "pos": [1, 2], "attrs": {"perception": 30}},
		{"template": "sergeant", "id": "sgt", "pos": [6, 2]},
		{"id": "gen", "name": "Pack", "team": "object", "hp": 1, "hidden": true,
			"on_destroy": {"attached_to": "sgt", "disable_deflector": "sgt"}}]
	var c = _arena(OPEN, units, {"insights": [{"id": "pack", "dc": 10, "reveals": "gen", "text": "Backpack generator."}]})
	c.force_turn("deena")
	check(not ("attack:gen" in _ids(c)), "generator hidden before Search")
	c.act("search")
	c.force_turn("deena")
	check("attack:gen" in _ids(c), "Search reveals the generator")
	var pv: Dictionary = c.preview_attack(c.by_id["deena"], c.by_id["gen"])
	eq(pv.reflected_by, "", "a shot at the pack itself isn't reflected")
	for i in 10:
		if c.by_id["gen"].dead:
			break
		c.force_turn("deena")
		c.act("attack:gen")
	check(c.by_id["gen"].dead, "generator destroyed")
	check(not c.by_id["sgt"].deflector, "Deflector disabled")

func test_pass_turn_lets_slow_ally_act_now() -> void:
	var c = _arena(OPEN, [{"template": "deena", "id": "deena", "pos": [1, 1]}, {"template": "ksaabu", "id": "k", "pos": [1, 3]},
		{"template": "thug", "id": "t1", "pos": [8, 4]}])
	eq(c.current_id, "deena", "Deena first")
	c.act("pass:k")
	eq(c.current_id, "k", "K'saabu acts immediately")
	eq(c.by_id["deena"].cooldowns.get("pass_turn"), 4, "cooldown 3 (counted from her next turn)")
	check(not ("hold" in _ids(c)), "a passed turn can't be held")

func test_back_attacks_hit_harder() -> void:
	var c = _arena(OPEN, [{"template": "dust", "id": "dust", "pos": [4, 2]}, {"template": "thug", "id": "t1", "pos": [5, 2], "facing": [1, 0]}])
	var back: Dictionary = c.preview_attack(c.by_id["dust"], c.by_id["t1"])
	c.by_id["t1"].facing = Vector2i(-1, 0)
	var front: Dictionary = c.preview_attack(c.by_id["dust"], c.by_id["t1"])
	eq(back.relation, "back", "attacker behind the target")
	check(back.hit > front.hit and back.max > front.max, "back attack: more hit chance and damage")

func test_leaving_reach_provokes_opportunity_attack() -> void:
	var c = _arena(OPEN, [{"template": "deena", "id": "deena", "pos": [4, 2]}, {"template": "thug", "id": "t1", "pos": [5, 2]}])
	c.force_turn("deena")
	c.act("move:1,2")
	check(c.narration.any(func(l): return "attack of opportunity" in l), "thug reacts")
	check(not c.by_id["t1"].reaction_available, "reaction spent")

func test_party_member_is_downed_then_revived() -> void:
	var c = _arena(OPEN, [{"template": "dust", "id": "dust", "pos": [2, 2]}, {"template": "deena", "id": "deena", "pos": [3, 2]},
		{"template": "thug", "id": "t1", "pos": [8, 4]}])
	c.deal(c.by_id["deena"], 999, 0, "test")
	eq(c.by_id["deena"].downed_turns, 3, "Downed for 3 turns, not dead")
	check(not c.by_id["deena"].dead, "not dead")
	c.force_turn("dust")
	c.act("revive:deena")
	check(c.by_id["deena"].can_act(), "revived")

func test_dust_out_is_game_over() -> void:
	var c = _arena(OPEN, [{"template": "dust", "id": "dust", "pos": [2, 2]}, {"template": "ashe", "id": "ashe", "pos": [3, 2]},
		{"template": "thug", "id": "t1", "pos": [8, 4]}])
	c.by_id["dust"].out = true
	c._check_outcome()
	eq(c.outcome, "defeat", "Dust Out = game over")

func test_collateral_civilian_can_be_shoved_clear() -> void:
	var c = _arena(OPEN, [{"template": "dust", "id": "dust", "pos": [2, 2]}, {"id": "civ", "name": "Dockhand", "team": "civilian", "hp": 20, "pos": [3, 2]},
		{"template": "thug", "id": "t1", "pos": [8, 4]}])
	c.force_turn("dust")
	eq(c.shove_chance(c.by_id["dust"], c.by_id["civ"]), 100, "civilians always move when told")
	c.act("shove:civ")
	eq(c.by_id["civ"].pos, Vector2i(5, 2), "dockhand moved 2 tiles away")

func test_explosive_object_chains() -> void:
	var c = _arena(OPEN, [{"template": "deena", "id": "deena", "pos": [1, 1]}, {"template": "thug", "id": "t1", "pos": [6, 2]},
		{"id": "cell", "name": "Fuel cell", "team": "object", "hp": 1, "pos": [6, 3], "on_destroy": {"explode": 20}}])
	c.deal(c.by_id["cell"], 5, 0, "test")
	check(c.by_id["t1"].hp < c.by_id["t1"].max_hp, "blast hits the thug next to the cell")

func test_party_autoplay_clears_every_test_arena() -> void:
	for id in Data.arena_ids():
		for s in [1, 2, 3]:
			var c = Data.new_combat(id, s)
			eq(AI.autoplay(c), "victory", "Standing Orders win %s (seed %d)" % [id, s])
