extends "res://tests/unit/test_case.gd"

const Combat = preload("res://engine/combat.gd")
const Data = preload("res://engine/data.gd")

const OPEN := ["##########", "#........#", "#........#", "#........#", "#........#", "##########"]

func _arena(units: Array) -> RefCounted:
	var chars: Dictionary = Data.characters()
	var us := []
	for ud in units:
		var m: Dictionary = chars[ud["template"]].duplicate(true) if ud.has("template") else {}
		for k in ud.keys():
			m[k] = ud[k]
		us.append(m)
	var c = Combat.from_arena({"id": "t", "name": "t", "map": OPEN, "units": us}, 5)
	c.start()
	return c

func _ids(c) -> Array:
	return c.legal_actions().map(func(a): return a.id)

func _run_turns_of(c, id: String, n: int) -> void:
	# Give unit `id` n of its own turns while it's Downed.
	for i in n:
		c.current_id = id
		c.bonus_turn = true
		c._begin_turn(c.by_id[id])

func test_taz_survives_eight_downed_turns() -> void:
	var c = _arena([{"template": "dust", "id": "dust", "pos": [1, 1]}, {"template": "taz", "id": "taz", "pos": [3, 3]},
		{"template": "thug", "id": "t1", "pos": [8, 4]}])
	c.deal(c.by_id["taz"], 999, 0, "test")
	eq(c.by_id["taz"].downed_turns, 8, "Taz is Downed for 8 turns (normal is 3)")
	_run_turns_of(c, "taz", 8)
	check(not c.by_id["taz"].dead, "still alive after 8 Downed turns tick down to the last")
	_run_turns_of(c, "taz", 1)
	check(c.by_id["taz"].dead, "dies when the timer runs out")

func test_side_character_death_ends_arc_not_game() -> void:
	var c = _arena([{"template": "dust", "id": "dust", "pos": [1, 1]}, {"template": "taz", "id": "taz", "pos": [3, 3], "downed_limit": 1},
		{"template": "thug", "id": "t1", "pos": [8, 4]}])
	c.deal(c.by_id["taz"], 999, 0, "test")
	_run_turns_of(c, "taz", 2)
	check(c.by_id["taz"].dead, "Taz dies")
	eq(c.fallen, ["taz"], "his arc is recorded as ended")
	c.outcome = ""
	c._check_outcome()
	eq(c.outcome, "", "the fight goes on")

func test_main_character_death_is_game_over() -> void:
	var c = _arena([{"template": "dust", "id": "dust", "pos": [1, 1]}, {"template": "deena", "id": "deena", "pos": [3, 3]},
		{"template": "thug", "id": "t1", "pos": [8, 4]}])
	c.deal(c.by_id["deena"], 999, 0, "test")
	_run_turns_of(c, "deena", 4)
	eq(c.outcome, "defeat", "Deena dying is game over")

func test_mend_brings_back_a_downed_ally() -> void:
	var c = _arena([{"template": "dust", "id": "dust", "pos": [1, 1]}, {"template": "deena", "id": "deena", "pos": [4, 3]},
		{"template": "thug", "id": "t1", "pos": [8, 4]}])
	c.deal(c.by_id["deena"], 999, 0, "test")
	c.force_turn("dust")
	check("mend:deena" in _ids(c), "Mend can target a Downed ally at range")
	c.act("mend:deena")
	check(c.by_id["deena"].can_act() and c.by_id["deena"].hp >= 1, "healed to at least 1 HP and back up")

func test_just_some_punk_is_ignored_until_threatening() -> void:
	var c = _arena([{"template": "dust", "id": "dust", "pos": [1, 1]}, {"template": "taz", "id": "taz", "pos": [5, 2], "unnoticed": true},
		{"template": "thug", "id": "t1", "pos": [6, 2]}])
	c.force_turn("t1")
	check(not ("attack:taz" in _ids(c)), "the thug won't bother with the punk")
	c.force_turn("taz")
	c.act("move:5,3")
	check(c.by_id["taz"].has_status("unnoticed"), "walking around is fine")
	c.force_turn("taz")
	c.act("attack:t1")
	check(not c.by_id["taz"].has_status("unnoticed"), "pulling the electro-axe gives him away")
	c.force_turn("t1")
	check("attack:taz" in _ids(c), "now he's a target")

func test_combat_drugs_can_grant_an_extra_action() -> void:
	var c = _arena([{"template": "dust", "id": "dust", "pos": [1, 1]}, {"template": "taz", "id": "taz", "pos": [5, 2], "drug_chance": 100},
		{"template": "thug", "id": "t1", "pos": [6, 2], "hp": 500}])
	c.current_id = "taz"
	c.bonus_turn = true
	c._begin_turn(c.by_id["taz"])
	c.act("attack:t1")
	eq(c.current_id, "taz", "still Taz's turn after one attack")
	check("attack:t1" in _ids(c), "and he can swing again")
