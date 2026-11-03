## Placeholder-box viewer for the test arenas (M1). Renders the rules state as boxes and
## lets Standing Orders play it out. Keys: Space = step one turn, A = autoplay on/off,
## N = next arena, R = restart.
extends Node3D

const Data = preload("res://engine/data.gd")
const AI = preload("res://engine/ai.gd")

const TEAM_COLORS := {"party": Color(0.95, 0.75, 0.3), "enemy": Color(0.85, 0.2, 0.25),
	"civilian": Color(0.5, 0.8, 0.95), "object": Color(0.6, 0.6, 0.6)}

var arenas: Array = []
var arena_index := 0
var combat
var auto := true
var timer := 0.0
var board: Node3D
var label: Label
var shot_path := ""
var shot_frames := 0

func _ready() -> void:
	arenas = Data.arena_ids()
	# Optional: -- --arena=<id> --turns=<n> --shot=<png>  (renders a screenshot and quits)
	var pre_turns := 0
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--arena="):
			arena_index = maxi(0, arenas.find(a.substr(8)))
		elif a.begins_with("--turns="):
			pre_turns = int(a.substr(8))
		elif a.begins_with("--shot="):
			shot_path = a.substr(7)
			auto = false
	var cam := Camera3D.new()
	cam.position = Vector3(9, 16, 16)
	add_child(cam)
	cam.look_at(Vector3(9, 0, 5.5))
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 30, 0)
	add_child(sun)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.05, 0.04, 0.08)
	env.environment.ambient_light_color = Color(0.4, 0.4, 0.5)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	add_child(env)
	board = Node3D.new()
	add_child(board)
	var ui := CanvasLayer.new()
	add_child(ui)
	label = Label.new()
	label.position = Vector2(12, 8)
	label.add_theme_font_size_override("font_size", 14)
	ui.add_child(label)
	_load()
	for i in pre_turns:
		if combat.outcome == "":
			AI.take_turn(combat)
	_redraw()

func _load() -> void:
	combat = Data.new_combat(arenas[arena_index], 1)
	combat.start()
	_redraw()

func _box(pos: Vector3, size: Vector3, color: Color) -> void:
	var m := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = size
	m.mesh = b
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	m.material_override = mat
	m.position = pos
	board.add_child(m)

func _redraw() -> void:
	for c in board.get_children():
		c.queue_free()
	var g = combat.grid
	for p in g.tiles.keys():
		var k: String = g.kind(p)
		var h: float = g.height_at(p) * 0.5
		match k:
			"wall": _box(Vector3(p.x, 0.75, p.y), Vector3(1, 1.5, 1), Color(0.25, 0.25, 0.3))
			"cover": _box(Vector3(p.x, 0.35, p.y), Vector3(0.9, 0.7, 0.9), Color(0.45, 0.35, 0.25))
			"water": _box(Vector3(p.x, -0.05, p.y), Vector3(1, 0.1, 1), Color(0.15, 0.3, 0.6))
			"door":
				var open: bool = g.doors[p].open
				_box(Vector3(p.x, 0.75 if not open else 0.05, p.y), Vector3(1, 1.5 if not open else 0.1, 0.3), Color(0.7, 0.55, 0.2))
			_:
				var shade := 0.18 if (p.x + p.y) % 2 == 0 else 0.22
				_box(Vector3(p.x, h - 0.05, p.y), Vector3(0.98, 0.1 + h * 2.0, 0.98), Color(shade, shade, shade + 0.03))
	for u in combat.units:
		if not u.is_active() or u.hidden or (u.is_object() and u.on_destroy.has("attached_to")):
			continue
		var col: Color = TEAM_COLORS.get(u.team, Color.WHITE)
		if u.downed_turns >= 0:
			col = col.darkened(0.6)
		var ht := 1.6 if not u.is_object() else 0.6
		var y0: float = combat.grid.height_at(u.pos) * 0.5
		_box(Vector3(u.pos.x, y0 + ht / 2.0, u.pos.y), Vector3(0.6, ht, 0.6), col)
		if u.id == combat.current_id:
			_box(Vector3(u.pos.x, y0 + ht + 0.3, u.pos.y), Vector3(0.2, 0.2, 0.2), Color.WHITE)
	var lines: Array = combat.narration.slice(maxi(0, combat.narration.size() - 10))
	var tl: Array = combat.timeline(8).map(func(t): return t.name)
	label.text = "%s   [Space] step  [A] auto:%s  [N] next  [R] restart\nTimeline: %s\n\n%s" % [
		combat.arena_name, "on" if auto else "off", "  >  ".join(tl), "\n".join(lines)]

func _process(delta: float) -> void:
	if shot_path != "":
		shot_frames += 1
		if shot_frames == 10:
			get_viewport().get_texture().get_image().save_png(shot_path)
			get_tree().quit()
		return
	if not auto or combat.outcome != "":
		return
	timer += delta
	if timer > 0.6:
		timer = 0.0
		_step()

func _step() -> void:
	if combat.outcome == "":
		AI.take_turn(combat)
	_redraw()

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed:
		match e.keycode:
			KEY_SPACE: _step()
			KEY_A: auto = not auto
			KEY_N:
				arena_index = (arena_index + 1) % arenas.size()
				_load()
			KEY_R: _load()
