## Full UI playtest of the Opening's three fights (needs a display, e.g. xvfb-run). For every party turn it
## takes the same plan the Standing-Orders AI would, but performs it through the real UI: mouse clicks on
## tiles and enemies, the action-bar buttons, and the E key. Reports click success and each fight's outcome.
##   xvfb-run -a -s "-screen 0 1920x1080x24" godot --path . --rendering-driver opengl3 --script tests/ui_playtest.gd
extends SceneTree

const AI = preload("res://engine/ai.gd")
const FIGHTS := ["F1", "F2", "F3"]

var game
var frame := 0
var fight_i := 0
var phase := "ffwd"
var wait := 0
var plan := {}
var expect_pos := Vector2i.ZERO
var clicks_ok := 0
var clicks_bad := 0
var buttons := 0
var results := {}
var shot_dir := ""
var shots_taken := {}

func _initialize() -> void:
	shot_dir = OS.get_environment("SHOT_DIR")
	game = load("res://ui/game.tscn").instantiate()
	root.add_child(game)

func _click(p: Vector2) -> void:
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = pressed
		var wp: Vector2 = root.get_final_transform() * p
		e.position = wp
		e.global_position = wp
		root.push_input(e)

func _key(k: Key) -> void:
	for pressed in [true, false]:
		var e := InputEventKey.new()
		e.keycode = k
		e.pressed = pressed
		root.push_input(e)

func _screen_of(tile: Vector2i) -> Vector2:
	var p: Vector2 = game.from_vp(game.cam.unproject_position(game.Blockout.tile_pos(game.sc.combat.grid, tile)))
	var where := "view"
	for n in [game.hud_panel, game.get_node("LogPanel"), game.tip_panel, game.title_lbl.get_parent().get_parent()]:
		if n.visible and n.get_global_rect().has_point(p):
			where = n.name
	if where != "view" or p.x < 0 or p.y < 0 or p.x > game.size.x or p.y > game.size.y:
		print("  target tile %s lands at %s, under %s (screen %s)" % [tile, p, where, game.size])
	return p

func _press_button(id: String) -> bool:
	# Find the action-bar button for this action and press it like a player would.
	for b in game.actions_box.get_children():
		if b is Button and b.has_meta("action_id") and b.get_meta("action_id") == id:
			b.emit_signal("pressed")
			buttons += 1
			return true
	return false

func _process(_d: float) -> bool:
	frame += 1
	if fight_i >= FIGHTS.size():
		var ok := results.values().all(func(r): return r == "victory") and clicks_bad == 0
		print("UI PLAYTEST: ", results, "  clicks ok %d, missed %d, buttons %d" % [clicks_ok, clicks_bad, buttons])
		quit(0 if ok else 1)
		return false
	var sc = game.sc
	var want: String = FIGHTS[fight_i]
	if phase == "ffwd":
		var guard := 0
		while not (sc.step().get("id", "") == want and sc.mode == "combat") and guard < 3000:
			game._agent_step(true)
			guard += 1
		game.tips.clear()
		game._refresh()
		phase = "play"
		wait = 20
		return false
	if wait > 0:
		wait -= 1
		return false
	if sc.mode != "combat" or sc.step().get("id", "") != want:
		results[want] = "victory" if sc.mode != "defeat" else "defeat"
		if sc.mode == "defeat":
			results[want] = "defeat"
		if plan.has("check_act") or plan.has("clicked_move"):
			clicks_ok += 1      # the last click ended the fight
		plan = {}
		fight_i += 1
		phase = "ffwd"
		return false
	var c = sc.combat
	var u = c.current()
	if u == null or u.team != "party":
		return false      # enemies act on their own timer in the game
	if shot_dir != "" and not shots_taken.has(want) and c.rounds_elapsed() >= 1:
		shots_taken[want] = true
		root.get_texture().get_image().save_png("%s/play_%s.png" % [shot_dir, want])
	if plan.is_empty():
		var plans: Array = AI._plans(c, u)
		plans.sort_custom(func(a, b): return a.score > b.score)
		plan = plans[0] if not plans.is_empty() else {"move": null, "action": ""}
		if plan.move != null and plan.move != u.pos and not c.turn.moved:
			expect_pos = plan.move
			_click(_screen_of(plan.move))
			plan["clicked_move"] = true
			wait = 4
			return false
	if plan.get("clicked_move", false):
		plan.erase("clicked_move")
		if u.pos == expect_pos:
			clicks_ok += 1
		else:
			clicks_bad += 1
			print("missed move click: %s wanted %s, at %s" % [u.name, expect_pos, u.pos])
	if c.current() != u:
		plan = {}
		return false
	var act: String = plan.get("action", "")
	plan["action"] = ""
	if act != "" and not c.turn.acted and c.legal_actions().any(func(a): return a.id == act):
		var before: int = c.events.size()
		if act.begins_with("attack:"):
			var tg = c.by_id[act.substr(7)]
			var sp := _screen_of(tg.pos)
			plan["dbg"] = "%s at %s h%d -> screen %s, mouse tile %s | before: me %s tg %s hp%d st%s" % [tg.name, tg.pos, c.grid.height_at(tg.pos), sp, game._tile_under_mouse(sp), u.pos, tg.pos, tg.hp, tg.statuses]
			plan["tg"] = tg
			_click(sp)
		elif act.begins_with("cannon:"):
			var xy := act.substr(7).split(",")
			_click(_screen_of(Vector2i(int(xy[0]), int(xy[1]))))
		elif not _press_button(act):
			print("no button for ", act)
			clicks_bad += 1
		plan["check_act"] = before
		plan["dbg_act"] = act
		wait = 4
		return false
	if plan.has("check_act"):
		if c.turn.acted or c.current() != u or c.events.size() > plan.check_act:
			clicks_ok += 1
		else:
			clicks_bad += 1
			print("action click did nothing for ", u.name, " ", plan.get("dbg", ""), " tip:", game.tip_panel.visible, game.tip_panel.get_global_rect(), " turn:", c.turn, " cur:", c.current_id, " after: me ", u.pos, " tg ", plan.tg.pos if plan.has("tg") else null, " hp ", plan.tg.hp if plan.has("tg") else 0, " st ", plan.tg.statuses if plan.has("tg") else null, " act:", plan.get("dbg_act", ""), " legal now:", c.legal_actions().any(func(a): return a.id == plan.get("dbg_act", "")))
		plan.erase("check_act")
	if c.current() == u and c.outcome == "":
		_key(KEY_E)
		wait = 3
	plan = {}
	return false
