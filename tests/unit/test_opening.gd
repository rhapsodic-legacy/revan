extends "res://tests/unit/test_case.gd"

const Session = preload("res://agent/dots_session.gd")
const Scenario = preload("res://engine/scenario.gd")
const Data = preload("res://engine/data.gd")
const Masher = preload("res://engine/masher.gd")

func test_every_scenario_line_exists_in_the_bible_extract() -> void:
	var spec: Dictionary = Data.load_json("res://data/scenarios/opening.json")
	var lines: Dictionary = Data.load_json("res://data/scenarios/opening_lines.json")
	var missing := []
	var walk := func(beats: Array, f: Callable) -> void:
		for b in beats:
			if b.has("line") and not lines.has(b.line):
				missing.append(b.line)
			if b.has("choice"):
				for o in b.choice:
					f.call(o.get("beats", []), f)
	for st in spec.steps:
		walk.call(st.get("beats", []), walk)
		walk.call(st.get("intro", []), walk)
		walk.call(st.get("outro", []), walk)
		for r in st.get("barks", []):
			if r.get("line") != null and not lines.has(r.line):
				missing.append(r.line)
	eq(missing, [], "all referenced line IDs exist")

func test_ai_agent_completes_the_opening_within_250_actions() -> void:
	# Acceptance test 7 (bible 05 §11), on Seer.
	for seed_v in [1, 2, 3]:
		var s = Session.new()
		var r: Dictionary = s.handle({"cmd": "play", "scenario": "opening", "seed": seed_v})
		var n := 0
		while r.state.mode != "end" and n < 400:
			r = s.handle({"cmd": "auto"})
			n += 1
		eq(r.state.mode, "end", "the agent finishes the Opening (seed %d)" % seed_v)
		check(n <= 250, "within 250 actions (seed %d took %d)" % [seed_v, n])
		check(r.state.flags.has("op.landing") and r.state.flags.get("op.tipoff_found", false), "landing and tip-off flags set")

func test_button_mashing_loses_f3_most_of_the_time() -> void:
	var losses := 0
	for s in range(1, 11):
		var c = Data.new_combat("op_f3_bay", s)
		if Masher.autoplay(c) != "victory":
			losses += 1
	check(losses >= 7, "button-mashers lose F3 (%d/10 losses)" % losses)

func test_door_play_cuts_off_the_sergeant() -> void:
	var sc = Scenario.load_id("opening", 1)
	while sc.mode != "combat" or sc.fight_step.id != "F3":
		if sc.mode == "combat":
			sc._scenario_skip_fight()
		elif sc.mode == "choice":
			sc.act("choose:%d" % (sc.choice.size() - 1))
		else:
			sc.act("next")
	var c = sc.combat
	# Stage it: the Sergeant on the pod side, a trooper on the ship side, Deena next to the panel.
	c.by_id["sergeant"].pos = Vector2i(12, 5)
	c.by_id["trooper_1"].pos = Vector2i(8, 7)
	c.by_id["deena"].pos = Vector2i(10, 3)
	for i in c.insights:
		if i.id == "door_battery":
			i.found = true
	c.force_turn("deena")
	check("use:door_panel" in c.legal_actions().map(func(a): return a.id), "the panel is usable once the Insight is found")
	sc.act("use:door_panel")
	check(c.events.any(func(e): return e.type == "door" and not e.open), "the bulkhead slams shut")
	eq(sc.flags.get("op.f3.solution"), "door", "the door play is recorded")
	check("F3_KSB_01" in sc.bark_log, "K'saabu's door bark fires")

func test_heavy_door_costs_the_whole_turn() -> void:
	var c = Data.new_combat("op_f3_bay", 1)
	c.start()
	c.grid.doors[Vector2i(11, 5)].open = false
	c.by_id["sergeant"].pos = Vector2i(12, 5)
	c.force_turn("sergeant")
	c.act("door:11,5")
	check(c.current_id != "sergeant", "opening the bulkhead ends his turn")

func test_back_hit_cracks_the_deflector() -> void:
	var c = Data.new_combat("op_f3_bay", 1)
	c.start()
	var sg = c.by_id["sergeant"]
	sg.pos = Vector2i(8, 5)
	sg.facing = Vector2i(-1, 0)
	c.by_id["dust"].pos = Vector2i(9, 5)
	for k in 6:
		if not sg.deflector:
			break
		c.force_turn("dust")
		sg.facing = Vector2i(-1, 0)
		c.act("attack:sergeant")
	check(not sg.deflector, "a hit from behind kills the Deflector")
