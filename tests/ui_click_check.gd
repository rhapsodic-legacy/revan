## UI smoke check (needs a display, e.g. xvfb-run): fast-forward to F1, click a blue tile, then click an enemy.
##   xvfb-run godot --path . --rendering-driver opengl3 --script tests/ui_click_check.gd
extends SceneTree

var game
var frame := 0
var stage := 0
var target_tile := Vector2i.ZERO
var start_pos := Vector2i.ZERO

func _initialize() -> void:
	game = load("res://ui/game.tscn").instantiate()
	root.add_child(game)

func _click(p: Vector2) -> void:
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = pressed
		var wp: Vector2 = root.get_final_transform() * p   # canvas -> window pixels, like a real mouse
		e.position = wp
		e.global_position = wp
		root.push_input(e)

func _screen_of(tile: Vector2i) -> Vector2:
	var wp: Vector3 = game.Blockout.tile_pos(game.sc.combat.grid, tile)
	return game.from_vp(game.cam.unproject_position(wp))

func _process(_d: float) -> bool:
	frame += 1
	if frame == 5:
		while not (game.sc.step().get("id", "") == "F1" and game.sc.mode == "combat"):
			game._agent_step(true)
		game._refresh()
	if frame == 40 and stage == 0:
		var c = game.sc.combat
		var u = c.current()
		start_pos = u.pos
		for a in c.legal_actions():
			if a.type == "move" and a.cost == 2:
				target_tile = Vector2i(a.to[0], a.to[1])
				break
		_click(_screen_of(target_tile))
		stage = 1
	if frame == 45 and stage == 1:
		var u = game.sc.combat.by_id[game.last_party_id]
		print("MOVE CLICK: ", "OK" if u.pos == target_tile else "FAILED (unit at %s, wanted %s)" % [u.pos, target_tile])
		get_root().get_texture().get_image().save_png("/tmp/claude-0/shots/ui_click.png")
		quit(0 if u.pos == target_tile else 1)
	return false
