## The playable game shell (M2): runs a Scenario with a low-res retro 3D view, dialogue box,
## choices, combat HUD, tutorial tips, timeline and Altitude meter. Placeholder art throughout.
##
## Controls: click / Space to advance dialogue; click a blue tile to move, an enemy to attack;
## the action bar has everything else. Command-line (after --): --auto (plays itself),
## --steps=N (fast-forward N agent actions), --shot=file.png (screenshot then quit), --seed=N.
extends Control

const Scenario = preload("res://engine/scenario.gd")
const AI = preload("res://engine/ai.gd")
const Blockout = preload("res://world/blockout.gd")
const DITHER = preload("res://render/dither.gdshader")

const SHRINK := 2
const COLORS := {
	"dust": Color(0.86, 0.62, 0.22), "ashe": Color(0.95, 0.93, 0.86), "deena": Color(0.30, 0.55, 1.0),
	"ksaabu": Color(0.22, 0.58, 0.32), "mama_quell": Color(1.0, 0.25, 0.7),
	"sergeant": Color(0.78, 0.78, 0.82), "breacher": Color(0.50, 0.42, 0.42), "marksman": Color(0.42, 0.48, 0.56),
}
const NAMES := {"dust": "Dust", "ashe": "Ashe", "deena": "Deena", "ksaabu": "K'saabu", "mama_quell": "Mama Quell"}
const SPEAKER_IDS := {"Dust": "dust", "Ashe": "ashe", "Deena": "deena", "K'saabu": "ksaabu", "Mama Quell": "mama_quell"}
const CAST := {
	"OP1": ["dust", "ashe"], "OP2": ["dust", "ashe"], "OP3": ["dust", "ashe", "deena", "ksaabu"],
	"OP4": ["dust", "ashe", "deena", "ksaabu"], "T1": ["dust", "ashe"], "T2": ["dust", "ashe", "deena", "ksaabu"],
	"OP5": ["dust", "deena", "ksaabu"], "OP6": ["dust", "ashe", "deena", "ksaabu", "mama_quell"],
}

var sc
var seed_value := 1
var auto_play := false
var shot_path := ""
var fast_steps := 0
var frames := 0
var until_step := ""
var until_extra := 0
var preview = null                  # an unstarted combat, to show a fight map during its intro

var vp: SubViewport
var svc: SubViewportContainer
var cam: Camera3D
var env: Environment
var world: Node3D
var env_root: Node3D
var door_root: Node3D
var unit_root: Node3D
var hl_root: Node3D
var built_key := ""
var cam_target := Vector3.ZERO
var cam_offset := Vector3(0, 9.5, 8.5)
var cam_pos_goal := Vector3.ZERO
var cam_look_goal := Vector3.ZERO
var cam_look := Vector3.ZERO
var follow := false                 # over-the-shoulder fight camera
var last_party_id := ""
var drift := 0.0

var title_lbl: Label
var alt_lbl: Label
var timeline_lbl: RichTextLabel
var dlg_panel: PanelContainer
var speaker_lbl: Label
var text_lbl: RichTextLabel
var choices_box: VBoxContainer
var hud_panel: PanelContainer
var card_lbl: RichTextLabel
var actions_box: HFlowContainer
var log_lbl: RichTextLabel
var tip_panel: PanelContainer
var tip_lbl: Label
var tips: Array = []
var hover_lbl: Label
var name_layer: Control
var name_tags := {}                 # unit node -> Label (crisp 2D labels over the low-res view)
var enemy_timer := 0.0
var auto_timer := 0.0

func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "--auto":
			auto_play = true
		elif a.begins_with("--shot="):
			shot_path = a.substr(7)
		elif a.begins_with("--steps="):
			fast_steps = int(a.substr(8))
		elif a.begins_with("--seed="):
			seed_value = int(a.substr(7))
		elif a.begins_with("--until="):
			var parts := a.substr(8).split(":")
			until_step = parts[0]
			until_extra = int(parts[1]) if parts.size() > 1 else 0
	set_anchors_preset(Control.PRESET_FULL_RECT)
	# The root must not swallow clicks, or the 3D view never sees them.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_view()
	_build_ui()
	sc = Scenario.load_id("opening", seed_value)
	sc.auto_enemies = false
	for i in fast_steps:
		if sc.mode == "end":
			break
		_agent_step(true)
	if until_step != "":
		var guard := 0
		while not (sc.step().get("id", "") == until_step and sc.mode == "combat") and sc.mode != "end" and guard < 2000:
			_agent_step(true)
			guard += 1
		for i in until_extra:
			_agent_step(true)
	_refresh()

# ------------------------------------------------------------------ construction

func _build_view() -> void:
	svc = SubViewportContainer.new()
	svc.set_anchors_preset(Control.PRESET_FULL_RECT)
	svc.stretch = true
	svc.stretch_shrink = SHRINK
	svc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	svc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := ShaderMaterial.new()
	m.shader = DITHER
	m.set_shader_parameter("pixel", float(SHRINK))
	svc.material = m
	add_child(svc)
	vp = SubViewport.new()
	vp.msaa_3d = Viewport.MSAA_DISABLED
	svc.add_child(vp)
	world = Node3D.new()
	vp.add_child(world)
	cam = Camera3D.new()
	cam.fov = 55
	world.add_child(cam)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-60, 35, 0)
	sun.light_energy = 0.9
	world.add_child(sun)
	var we := WorldEnvironment.new()
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.45, 0.45, 0.55)
	env.fog_enabled = true
	env.fog_density = 0.03
	we.environment = env
	world.add_child(we)
	for n in ["env", "doors", "units", "hl"]:
		var node := Node3D.new()
		node.name = n
		world.add_child(node)
	env_root = world.get_node("env")
	door_root = world.get_node("doors")
	unit_root = world.get_node("units")
	hl_root = world.get_node("hl")

func _panel(bg: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = Color(0.2, 0.85, 0.9, 0.8)
	sb.set_border_width_all(2)
	sb.set_content_margin_all(10)
	p.add_theme_stylebox_override("panel", sb)
	return p

func _build_ui() -> void:
	var top := _panel(Color(0, 0, 0, 0.55))
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = 64
	add_child(top)
	var tv := VBoxContainer.new()
	top.add_child(tv)
	var row := HBoxContainer.new()
	tv.add_child(row)
	title_lbl = Label.new()
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title_lbl)
	alt_lbl = Label.new()
	alt_lbl.add_theme_font_size_override("font_size", 18)
	alt_lbl.add_theme_color_override("font_color", Color(1.0, 0.75, 0.2))
	row.add_child(alt_lbl)
	timeline_lbl = RichTextLabel.new()
	timeline_lbl.bbcode_enabled = true
	timeline_lbl.fit_content = true
	timeline_lbl.scroll_active = false
	tv.add_child(timeline_lbl)

	dlg_panel = _panel(Color(0.02, 0.02, 0.06, 0.88))
	dlg_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	dlg_panel.offset_top = -210
	dlg_panel.offset_left = 120
	dlg_panel.offset_right = -120
	dlg_panel.offset_bottom = -16
	add_child(dlg_panel)
	var dv := VBoxContainer.new()
	dlg_panel.add_child(dv)
	speaker_lbl = Label.new()
	speaker_lbl.add_theme_font_size_override("font_size", 20)
	speaker_lbl.add_theme_color_override("font_color", Color(0.3, 0.95, 1.0))
	dv.add_child(speaker_lbl)
	text_lbl = RichTextLabel.new()
	text_lbl.bbcode_enabled = true
	text_lbl.fit_content = true
	text_lbl.custom_minimum_size = Vector2(0, 60)
	text_lbl.add_theme_font_size_override("normal_font_size", 18)
	text_lbl.add_theme_font_size_override("italics_font_size", 17)
	text_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dv.add_child(text_lbl)
	choices_box = VBoxContainer.new()
	dv.add_child(choices_box)

	hud_panel = _panel(Color(0.02, 0.02, 0.06, 0.62))
	hud_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hud_panel.offset_top = -150
	hud_panel.offset_right = -330
	add_child(hud_panel)
	var hh := HBoxContainer.new()
	hud_panel.add_child(hh)
	card_lbl = RichTextLabel.new()
	card_lbl.bbcode_enabled = true
	card_lbl.custom_minimum_size = Vector2(250, 120)
	card_lbl.scroll_active = false
	hh.add_child(card_lbl)
	actions_box = HFlowContainer.new()
	actions_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hh.add_child(actions_box)

	var logp := _panel(Color(0, 0, 0, 0.45))
	logp.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	logp.offset_left = -330
	logp.offset_top = 70
	logp.offset_bottom = -16
	logp.name = "LogPanel"
	add_child(logp)
	log_lbl = RichTextLabel.new()
	log_lbl.bbcode_enabled = true
	log_lbl.scroll_following = true
	log_lbl.add_theme_font_size_override("normal_font_size", 13)
	logp.add_child(log_lbl)

	tip_panel = _panel(Color(0.08, 0.06, 0.0, 0.9))
	tip_panel.position = Vector2(16, 80)
	tip_panel.custom_minimum_size = Vector2(380, 0)
	add_child(tip_panel)
	var tvb := VBoxContainer.new()
	tip_panel.add_child(tvb)
	tip_lbl = Label.new()
	tip_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip_lbl.custom_minimum_size = Vector2(360, 0)
	tip_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	tvb.add_child(tip_lbl)
	var tb := Button.new()
	tb.text = "Got it"
	tb.pressed.connect(func(): tips.pop_front(); _refresh_tip())
	tvb.add_child(tb)

	name_layer = Control.new()
	name_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	name_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(name_layer)
	move_child(name_layer, 1)
	hover_lbl = Label.new()
	hover_lbl.add_theme_color_override("font_color", Color.WHITE)
	hover_lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	hover_lbl.visible = false
	add_child(hover_lbl)

# ------------------------------------------------------------------ refresh

func _refresh() -> void:
	var st: Dictionary = sc.step()
	var key: String = "%s#%d#%s" % [st.get("id", "end"), sc.attempts, sc.combat != null]
	if key != built_key:
		built_key = key
		_build_world(st)
	var stitle: String = st.get("title", "")
	title_lbl.text = "Fast and Hard  ·  %s" % stitle if stitle != "" else "Fast and Hard"
	var alt: int = sc.fight_altitude()
	alt_lbl.text = "ALTITUDE %s m" % Scenario._fmt(alt) if alt >= 0 else ""
	var in_combat: bool = sc.mode == "combat"
	dlg_panel.visible = not in_combat
	hud_panel.visible = in_combat
	get_node("LogPanel").visible = in_combat
	timeline_lbl.visible = in_combat
	if in_combat:
		_refresh_combat()
	else:
		_refresh_dialogue()
	_refresh_tip()

func _refresh_dialogue() -> void:
	for c in choices_box.get_children():
		c.queue_free()
	var b: Dictionary = sc.current_beat
	if sc.mode == "choice":
		speaker_lbl.text = "Dust"
		text_lbl.text = "[i]What do you say?[/i]"
		for i in sc.choice.size():
			var btn := Button.new()
			btn.text = "▸ " + sc.choice[i].text
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			var id := "choose:%d" % i
			btn.pressed.connect(func(): _do(id))
			choices_box.add_child(btn)
	elif sc.mode == "defeat":
		speaker_lbl.text = "Defeat"
		text_lbl.text = "[i]%s[/i]" % b.get("narrate", "")
		var btn := Button.new()
		btn.text = "Retry the fight"
		btn.pressed.connect(func(): _do("retry"))
		choices_box.add_child(btn)
	elif b.has("narrate"):
		speaker_lbl.text = ""
		text_lbl.text = "[i]%s[/i]" % b.narrate
	else:
		speaker_lbl.text = b.get("speaker", "")
		var t: String = b.get("text", "")
		var dir: String = b.get("dir", "")
		var s := ""
		if dir != "":
			s += "[color=#8899aa][i](%s)[/i][/color] " % dir
		s += t
		if b.get("subtitle", "") != "":
			s += "\n[color=#9fe39f][i](%s)[/i][/color]" % b.subtitle
		text_lbl.text = s
		_highlight_speaker(SPEAKER_IDS.get(b.get("speaker", ""), ""))
	if sc.mode == "end":
		speaker_lbl.text = ""
		text_lbl.text = "[i]End of the Opening. Act I is next.[/i]"

func _refresh_combat() -> void:
	var c = sc.combat
	_sync_units()
	Blockout.refresh_doors(door_root, c, sc.step().get("location", ""))
	# Timeline
	var parts := []
	for t in c.timeline(10):
		var col := "#ffd27a" if t.team == "party" else "#ff6a6a"
		parts.append("[color=%s]%s%s[/color]" % [col, "▶ " if t.get("now", false) else "", t.name])
	timeline_lbl.text = "  ·  ".join(parts)
	# Log
	var lines: Array = c.narration.slice(maxi(0, c.narration.size() - 40))
	log_lbl.text = "\n".join(lines.map(func(l): return _fmt_log(l)))
	# Card + actions
	var u = c.current()
	for ch in actions_box.get_children():
		ch.queue_free()
	_clear_highlights()
	if u == null:
		return
	var st := ""
	for k in u.statuses.keys():
		st += k.replace("_", " ").capitalize() + " "
	card_lbl.text = "[b]%s[/b]  [color=#8899aa]Lv %d[/color]\nHP %d/%d%s\nFocus %d   Move %d\n%s\n[color=#8899aa]%s[/color]" % [
		u.name, u.level, u.hp, u.max_hp, ("   Shield %d" % u.shield) if u.shield > 0 else "", int(u.focus), u.move,
		"[color=#ffd27a]Your turn[/color]" if u.team == "party" else "[color=#ff6a6a]Enemy turn[/color]", st]
	if u.team != "party":
		return
	var legal: Array = c.legal_actions()
	for a in legal:
		match a.type:
			"move":
				_hl(Vector2i(a.to[0], a.to[1]), Color(0.2, 0.6, 1.0), 0.45)
			"dash":
				_hl(Vector2i(a.to[0], a.to[1]), Color(0.15, 0.3, 0.8), 0.3)
			"attack", "cannon":
				var tp: Vector2i = c.by_id[a.target].pos if a.type == "attack" else Vector2i(a.center[0], a.center[1])
				var refl: bool = a.preview.get("reflected_by", "") != ""
				_hl(tp, Color(1.0, 0.6, 0.1) if refl else Color(1.0, 0.15, 0.15), 0.6)
				_action_button(a)
			_:
				_action_button(a)

func _action_button(a: Dictionary) -> void:
	var c = sc.combat
	var label = a.id
	var tip := ""
	match a.type:
		"attack":
			var pv: Dictionary = a.preview
			label = "Attack %s  %d%%  %d-%d" % [c.by_id[a.target].name, pv.hit, pv.min, pv.max]
			if pv.relation != "front":
				label += "  (%s)" % pv.relation
			if pv.reflected_by != "":
				label += "  ⚠ REFLECTED"
		"cannon":
			var names: Array = a.preview.hits.map(func(i): return c.by_id[i].name)
			label = "Cannon → %s" % ", ".join(names)
			if a.preview.reflected_by != "":
				label = "⚠ Cannon (REFLECTED onto you)"
		"search": label = "Search"
		"hold": label = "Hold"
		"end": label = "End turn"
		"taunt": label = "Taunt"
		"shield": label = "Raise Shield"
		"door": label = "%s door" % a.will.capitalize()
		"lock": label = "Lock door"
		"break_door": label = "Break door (%d HP)" % a.door_hp
		"use": label = "Use: %s" % a.name
		"pass_turn": label = "Pass Turn → %s" % c.by_id[a.target].name
		"mend": label = "Mend %s (+%d)" % [c.by_id[a.target].name, a.heal]
		"shove": label = "Shove %s (%d%%)" % [c.by_id[a.target].name, a.chance]
		"push": label = "Push %s (%d%%)" % [c.by_id[a.target].name, a.chance]
		"revive": label = "Revive %s" % c.by_id[a.target].name
		"grenade": label = "Stun Grenade (%d caught)" % a.hits.size()
	var b := Button.new()
	b.text = label
	b.add_theme_font_size_override("font_size", 13)
	var id: String = a.id
	b.pressed.connect(func(): _do(id))
	actions_box.add_child(b)

func _fmt_log(l: String) -> String:
	if l.begins_with("TIP: "):
		return "[color=#ffd27a]%s[/color]" % l
	if l.contains(": \""):
		return "[color=#7fe7ff]%s[/color]" % l
	if l.contains("falls") or l.contains("Downed") or l.contains("dies"):
		return "[color=#ff7a7a]%s[/color]" % l
	return l

func _refresh_tip() -> void:
	tip_panel.visible = not tips.is_empty() and sc.mode == "combat"
	if not tips.is_empty():
		tip_lbl.text = "TIP  " + tips[0]

# ------------------------------------------------------------------ 3D

func _build_world(st: Dictionary) -> void:
	for n in [env_root, door_root, unit_root, hl_root]:
		for c in n.get_children():
			c.queue_free()
	var loc: String = st.get("location", "galactic_c_workshop")
	var th: Dictionary = Blockout.theme(loc)
	env.background_color = th.fog
	env.fog_light_color = th.fog
	if st.get("type", "") == "fight":
		var fc = sc.combat
		if fc == null:
			preview = load("res://engine/data.gd").new_combat(st.arena, 1)
			fc = preview
			Blockout.refresh_doors(door_root, fc, loc)
		Blockout.build_arena(env_root, fc, loc)
		var g = fc.grid
		cam_target = Vector3((g.width - 1) / 2.0, 0, (g.height - 1) / 2.0)
		cam_offset = Vector3(0, 0.95, 0.7) * maxf(g.width, g.height * 1.4) * 0.72
		follow = true
		tips = st.get("prompts", []).duplicate() if sc.combat != null else []
		if sc.combat == null:
			_sync_units(preview)
	else:
		Blockout.build_set(env_root, loc)
		var cast: Array = CAST.get(st.get("id", ""), ["dust", "ashe"])
		for i in cast.size():
			var x := (i - (cast.size() - 1) / 2.0) * 1.4
			var z := 0.5 if loc != "lowlight_street" else 1.5
			if cast[i] == "mama_quell":
				x = -3.5
				z = 2.5
			var n := _make_unit(cast[i], NAMES.get(cast[i], cast[i]), COLORS.get(cast[i], Color.WHITE), cast[i] == "ksaabu")
			n.position = Vector3(x, 0, z)
			n.rotation.y = PI
			unit_root.add_child(n)
		cam_target = Vector3(0, 1.0, 0)
		cam_offset = Vector3(0, 2.2, 6.5) if loc != "lowlight_street" else Vector3(0, 2.5, 8.5)
		follow = false
	_place_cam(true)

func _place_cam(snap := false) -> void:
	if follow:
		_shoulder_goal()
	else:
		cam_pos_goal = cam_target + cam_offset + Vector3(sin(drift * 0.25) * 0.4, 0, 0)
		cam_look_goal = cam_target
	var k := 1.0 if snap else 0.08
	cam.position = cam.position.lerp(cam_pos_goal, k)
	cam_look = cam_look.lerp(cam_look_goal, k)
	if cam.position.distance_to(cam_look) > 0.01:
		cam.look_at(cam_look, Vector3.UP)
	_cull_walls()
	_update_tags()

## Hide outer walls standing between the camera and the action (cutaway view).
func _cull_walls() -> void:
	var fwd := -cam.global_transform.basis.z
	var focus: float = cam.position.distance_to(cam_look) * 0.55
	for w in get_tree().get_nodes_in_group("cull_wall"):
		var along: float = (w.position - cam.position).dot(fwd)
		w.visible = not follow or along > focus

## Behind and above the acting hero, over the right shoulder, looking at the enemy.
func _shoulder_goal() -> void:
	var c = sc.combat if sc.combat != null else preview
	if c == null:
		return
	var u = c.current()
	if u == null or u.team != "party":
		u = c.by_id.get(last_party_id)
	if u == null or not u.is_active():
		for x in c.units:
			if x.team == "party" and x.is_active():
				u = x
				break
	if u == null:
		return
	last_party_id = u.id
	var me := Blockout.tile_pos(c.grid, u.pos)
	var foes := Vector3.ZERO
	var n := 0
	for x in c.units:
		if x.team == "enemy" and x.is_active():
			foes += Blockout.tile_pos(c.grid, x.pos)
			n += 1
	var dir := Vector3(0, 0, -1)
	if n > 0:
		var d := foes / n - me
		d.y = 0
		if d.length() > 0.5:
			dir = d.normalized()
	var right := dir.cross(Vector3.UP).normalized()
	cam_pos_goal = me - dir * 4.2 + right * 1.3 + Vector3(0, 3.6, 0)
	cam_look_goal = me + dir * 4.5 + Vector3(0, 0.3, 0)

func _update_tags() -> void:
	var live := {}
	for n in unit_root.get_children():
		if n.is_queued_for_deletion() or not n.has_meta("tag"):
			continue
		live[n] = true
		var l: Label = name_tags.get(n)
		if l == null:
			l = Label.new()
			l.add_theme_font_size_override("font_size", 14)
			l.add_theme_color_override("font_outline_color", Color.BLACK)
			l.add_theme_constant_override("outline_size", 5)
			name_layer.add_child(l)
			name_tags[n] = l
		var wp: Vector3 = n.global_position + Vector3(0, n.get_meta("tag_h"), 0)
		l.visible = not cam.is_position_behind(wp)
		l.text = n.get_meta("tag")
		l.add_theme_color_override("font_color", n.get_meta("tag_col"))
		var sp: Vector2 = from_vp(cam.unproject_position(wp))
		l.position = sp - Vector2(l.size.x / 2.0, l.size.y)
	for n in name_tags.keys():
		if not live.has(n):
			name_tags[n].queue_free()
			name_tags.erase(n)

func _make_unit(id: String, label: String, col: Color, big := false) -> Node3D:
	var n := Node3D.new()
	n.name = id
	var body := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.42 if big else 0.26
	cap.height = 1.5 if big else 1.35
	cap.radial_segments = 10
	cap.rings = 4
	body.mesh = cap
	body.material_override = Blockout.mat(col)
	body.position.y = cap.height / 2.0
	n.add_child(body)
	Blockout.sphere(n, Vector3(0, cap.height + 0.18, 0), 0.2 if not big else 0.28, col.lightened(0.15))
	Blockout.box(n, Vector3(0, cap.height * 0.65, -cap.radius), Vector3(0.18, 0.1, 0.12), col.darkened(0.5))
	n.set_meta("tag", label)
	n.set_meta("tag_h", cap.height + 0.7)
	n.set_meta("tag_col", Color(1, 1, 1))
	return n

func _unit_color(u) -> Color:
	if COLORS.has(u.id):
		return COLORS[u.id]
	if u.id.begins_with("trooper"):
		return Color(0.55, 0.56, 0.62)
	return Color(0.6, 0.6, 0.6)

func _sync_units(c = null) -> void:
	if c == null:
		c = sc.combat
	var seen := {}
	for u in c.units:
		if u.is_object() or u.hidden:
			continue
		seen[u.id] = true
		var n: Node3D = unit_root.get_node_or_null(u.id)
		if not u.is_active():
			if n != null:
				n.queue_free()
			continue
		if n == null:
			n = _make_unit(u.id, u.name, _unit_color(u), u.id == "ksaabu")
			unit_root.add_child(n)
		n.position = Blockout.tile_pos(c.grid, u.pos)
		n.rotation = Vector3(0, atan2(-u.facing.x, -u.facing.y), 0)
		if u.downed_turns >= 0:
			n.rotation.x = -PI / 2.2
		n.set_meta("tag", "%s  %d" % [u.name, u.hp])
		n.set_meta("tag_col", Color(1, 0.9, 0.3) if u.id == c.current_id else (Color(0.85, 0.95, 1) if u.team == "party" else Color(1, 0.6, 0.6)))
		var dome = n.get_node_or_null("dome")
		if u.deflector and dome == null:
			dome = Blockout.sphere(n, Vector3(0, 0.6, 0), 2.4, Color(0.4, 0.8, 1.0), 0.6, 0.18)
			dome.name = "dome"
		elif not u.deflector and dome != null:
			dome.queue_free()
		var sh = n.get_node_or_null("shield")
		if u.shield > 0 and sh == null:
			sh = Blockout.sphere(n, Vector3(0, 0.8, 0), 0.75 if u.id == "ksaabu" else 0.6, Color(0.5, 1.0, 0.6), 0.8, 0.25)
			sh.name = "shield"
		elif u.shield <= 0 and sh != null:
			sh.queue_free()

func _highlight_speaker(id: String) -> void:
	for n in unit_root.get_children():
		n.set_meta("tag_col", Color(1, 0.9, 0.3) if n.name == id else Color(0.75, 0.75, 0.8))

func _clear_highlights() -> void:
	for c in hl_root.get_children():
		c.queue_free()

func _hl(p: Vector2i, col: Color, alpha: float) -> void:
	var y: float = sc.combat.grid.height_at(p) * 0.5 + 0.03
	Blockout.box(hl_root, Vector3(p.x, y, p.y), Vector3(0.9, 0.04, 0.9), col, 0.8, alpha)

# ------------------------------------------------------------------ input & play

func _do(id: String) -> void:
	var r: Dictionary = sc.act(id)
	if not r.ok:
		push_warning(r.get("error", ""))
	_refresh()

## Canvas <-> 3D-view pixel conversion (the view renders at reduced resolution).
func to_vp(p: Vector2) -> Vector2:
	return (p - svc.global_position) * Vector2(vp.size) / svc.size

func from_vp(p: Vector2) -> Vector2:
	return p * svc.size / Vector2(vp.size) + svc.global_position

func _tile_under_mouse(pos: Vector2) -> Vector2i:
	var local := to_vp(pos)
	var from := cam.project_ray_origin(local)
	var dir := cam.project_ray_normal(local)
	if absf(dir.y) < 0.001:
		return Vector2i(-1, -1)
	for h in [0.5, 0.0]:
		var t: float = (h - from.y) / dir.y
		var hit := from + dir * t
		var p := Vector2i(roundi(hit.x), roundi(hit.z))
		if sc.combat.grid.in_bounds(p) and sc.combat.grid.height_at(p) * 0.5 == h:
			return p
	return Vector2i(-1, -1)

func _unhandled_input(e: InputEvent) -> void:
	if sc.mode == "dialogue" and ((e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT) \
			or (e is InputEventKey and e.pressed and e.keycode in [KEY_SPACE, KEY_ENTER])):
		_do("next")
		return
	if sc.mode != "combat" or sc.combat.current() == null or sc.combat.current().team != "party":
		return
	if e is InputEventMouseMotion:
		_hover(e.position)
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		var p := _tile_under_mouse(e.position)
		if p.x < 0:
			return
		var c = sc.combat
		var legal: Array = c.legal_actions()
		var u = c.unit_at(p)
		for a in legal:
			if u != null and a.type == "attack" and a.target == u.id:
				_do(a.id)
				return
			if a.type == "cannon" and Vector2i(a.center[0], a.center[1]) == p:
				_do(a.id)
				return
		for kind in ["move", "dash"]:
			var id := "%s:%d,%d" % [kind, p.x, p.y]
			if legal.any(func(a): return a.id == id):
				_do(id)
				return
	if e is InputEventKey and e.pressed and e.keycode == KEY_E:
		_do("end")

func _hover(pos: Vector2) -> void:
	var p := _tile_under_mouse(pos)
	hover_lbl.visible = false
	if p.x < 0:
		return
	var c = sc.combat
	var u = c.unit_at(p)
	if u == null:
		return
	var txt := "%s  HP %d/%d" % [u.name, u.hp, u.max_hp]
	if u.shield > 0:
		txt += "  Shield %d" % u.shield
	if u.deflector:
		txt += "  [Deflector]"
	for a in c.legal_actions():
		if a.type == "attack" and a.target == u.id:
			txt += "\nClick to attack: %d%% to hit, %d-%d dmg (%s)" % [a.preview.hit, a.preview.min, a.preview.max, a.preview.relation]
			if a.preview.reflected_by != "":
				txt += "\n⚠ Your shot will be REFLECTED"
	hover_lbl.text = txt
	hover_lbl.position = pos + Vector2(16, 16)
	hover_lbl.visible = true

## One action the way the DOTS agent's Standing Orders would take it.
func _agent_step(instant := false) -> void:
	match sc.mode:
		"combat":
			var c = sc.combat
			if c.current() != null:
				AI.take_turn(c)
			sc._after_combat_action()
			if instant:
				while sc.mode == "combat" and sc.combat.current() != null and sc.combat.current().team != "party":
					AI.take_turn(sc.combat)
					sc._after_combat_action()
		"dialogue":
			sc.act("next")
		"choice":
			sc.act("choose:0")
		"defeat":
			sc.act("retry")

func _process(delta: float) -> void:
	drift += delta
	_place_cam()
	frames += 1
	if shot_path != "":
		if frames == 12:
			get_viewport().get_texture().get_image().save_png(shot_path)
			get_tree().quit()
		return
	if sc.mode == "combat" and sc.combat.current() != null and sc.combat.current().team != "party":
		enemy_timer += delta
		if enemy_timer > 0.45:
			enemy_timer = 0.0
			AI.take_turn(sc.combat)
			sc._after_combat_action()
			_refresh()
		return
	if auto_play:
		auto_timer += delta
		if auto_timer > (0.9 if sc.mode != "combat" else 0.5):
			auto_timer = 0.0
			_agent_step()
			_refresh()
