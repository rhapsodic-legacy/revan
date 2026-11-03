## Placeholder environments built from primitives, themed per location (bible 04 §2.3).
## Fight maps come straight from the arena grid; dialogue scenes get a small set.
## Everything here is swapped for Tripo/Fal assets later; layouts and scale stay.
extends RefCounted

const RETRO := preload("res://render/retro.gdshader")

const THEMES := {
	"galactic_c_lounge": {"floor": Color(0.10, 0.32, 0.34), "floor2": Color(0.13, 0.38, 0.40), "wall": Color(0.62, 0.64, 0.70),
		"cover": Color(0.05, 0.55, 0.55), "furniture": Color(0.75, 0.75, 0.80), "accent": Color(1.0, 0.45, 0.15), "fog": Color(0.10, 0.06, 0.10)},
	"galactic_c_hold": {"floor": Color(0.16, 0.16, 0.18), "floor2": Color(0.19, 0.19, 0.21), "wall": Color(0.35, 0.36, 0.40),
		"cover": Color(0.55, 0.36, 0.16), "furniture": Color(0.62, 0.40, 0.18), "accent": Color(0.95, 0.80, 0.10), "fog": Color(0.05, 0.05, 0.08)},
	"galactic_c_bay": {"floor": Color(0.22, 0.23, 0.26), "floor2": Color(0.25, 0.26, 0.29), "wall": Color(0.55, 0.57, 0.62),
		"cover": Color(0.45, 0.45, 0.50), "furniture": Color(0.90, 0.90, 0.92), "accent": Color(0.95, 0.20, 0.25), "fog": Color(0.08, 0.04, 0.06)},
	"galactic_c_workshop": {"floor": Color(0.10, 0.32, 0.34), "floor2": Color(0.13, 0.38, 0.40), "wall": Color(0.70, 0.72, 0.78),
		"cover": Color(0.05, 0.55, 0.55), "furniture": Color(0.80, 0.80, 0.85), "accent": Color(1.0, 0.30, 0.75), "fog": Color(0.06, 0.05, 0.10)},
	"galactic_c_cockpit": {"floor": Color(0.12, 0.12, 0.15), "floor2": Color(0.14, 0.14, 0.17), "wall": Color(0.30, 0.31, 0.36),
		"cover": Color(0.20, 0.22, 0.26), "furniture": Color(0.25, 0.27, 0.32), "accent": Color(0.20, 0.85, 1.0), "fog": Color(0.03, 0.03, 0.07)},
	"lowlight_street": {"floor": Color(0.05, 0.05, 0.08), "floor2": Color(0.07, 0.07, 0.10), "wall": Color(0.18, 0.15, 0.20),
		"cover": Color(0.25, 0.20, 0.25), "furniture": Color(0.30, 0.25, 0.30), "accent": Color(1.0, 0.25, 0.70), "fog": Color(0.10, 0.04, 0.14)},
}

static var _mats := {}

static func mat(color: Color, emission := 0.0, alpha := 1.0) -> ShaderMaterial:
	var key := "%s|%s|%s" % [color.to_html(), emission, alpha]
	if _mats.has(key):
		return _mats[key]
	var m := ShaderMaterial.new()
	m.shader = RETRO
	m.set_shader_parameter("albedo", color)
	m.set_shader_parameter("emission", emission)
	m.set_shader_parameter("alpha", alpha)
	if alpha < 0.99:
		m.render_priority = 1
	_mats[key] = m
	return m

static func box(parent: Node, pos: Vector3, size: Vector3, color: Color, emission := 0.0, alpha := 1.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = size
	mi.mesh = b
	mi.material_override = mat(color, emission, alpha)
	mi.position = pos
	parent.add_child(mi)
	return mi

static func sphere(parent: Node, pos: Vector3, r: float, color: Color, emission := 0.0, alpha := 1.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = 12
	s.rings = 6
	mi.mesh = s
	mi.material_override = mat(color, emission, alpha)
	mi.position = pos
	parent.add_child(mi)
	return mi

static func theme(location: String) -> Dictionary:
	return THEMES.get(location, THEMES["galactic_c_bay"])

static func tile_pos(grid, p: Vector2i) -> Vector3:
	return Vector3(p.x, grid.height_at(p) * 0.5, p.y)

## Builds a fight map from the combat grid.
static func build_arena(parent: Node3D, combat, location: String) -> void:
	var th := theme(location)
	var g = combat.grid
	for p in g.tiles.keys():
		var k: String = g.kind(p)
		var h: float = g.height_at(p) * 0.5
		var border: bool = p.x == 0 or p.y == 0 or p.x == g.width - 1 or p.y == g.height - 1
		match k:
			"wall":
				if border:
					box(parent, Vector3(p.x, 1.25, p.y), Vector3(1, 2.5, 1), th.wall)
					if location == "galactic_c_lounge" and p.y == 0 and p.x % 3 == 1:
						box(parent, Vector3(p.x, 1.5, p.y + 0.51), Vector3(0.8, 0.9, 0.02), th.accent, 1.2)
				else:
					# Interior "walls" are furniture: bar counter, crates, check-in desk.
					box(parent, Vector3(p.x, -0.05, p.y), Vector3(1, 0.1, 1), th.floor)
					var tall := 1.6 if location == "galactic_c_hold" else 1.1
					box(parent, Vector3(p.x, tall / 2.0, p.y), Vector3(0.96, tall, 0.96), th.furniture)
					box(parent, Vector3(p.x, tall + 0.02, p.y), Vector3(0.96, 0.04, 0.96), th.accent, 0.4)
			"cover":
				box(parent, Vector3(p.x, -0.05, p.y), Vector3(1, 0.1, 1), th.floor)
				box(parent, Vector3(p.x, 0.3, p.y), Vector3(0.85, 0.6, 0.6), th.cover)
				box(parent, Vector3(p.x, 0.7, p.y - 0.22), Vector3(0.85, 0.5, 0.15), th.cover.darkened(0.2))
			"water":
				box(parent, Vector3(p.x, -0.1, p.y), Vector3(1, 0.05, 1), Color(0.1, 0.25, 0.5), 0.3)
			"door":
				box(parent, Vector3(p.x, -0.05, p.y), Vector3(1, 0.1, 1), th.accent.darkened(0.5))
			_:
				var c: Color = th.floor if (p.x + p.y) % 2 == 0 else th.floor2
				if h > 0:
					box(parent, Vector3(p.x, h / 2.0 - 0.05, p.y), Vector3(1, h + 0.1, 1), c.lightened(0.08))
					box(parent, Vector3(p.x, h + 0.01, p.y), Vector3(1, 0.02, 0.1), th.accent, 0.6)
				else:
					box(parent, Vector3(p.x, -0.05, p.y), Vector3(1, 0.1, 1), c)
	# Doors are rebuilt by refresh_doors so they can open and close.
	for pr in combat.props:
		var pp := Vector3(pr.pos[0], 0, pr.pos[1])
		if pr.kind == "door_panel":
			box(parent, pp + Vector3(0.3, 1.2, 0), Vector3(0.15, 0.4, 0.4), Color(1.0, 0.85, 0.2), 1.5)
		elif pr.kind == "drop":
			for tp in pr.tiles:
				box(parent, Vector3(tp[0], 2.3, tp[1]), Vector3(0.95, 0.15, 0.9), Color(0.5, 0.45, 0.4))

static func refresh_doors(parent: Node3D, combat, location: String) -> void:
	for c in parent.get_children():
		c.queue_free()
	var th := theme(location)
	var g = combat.grid
	for p in g.doors.keys():
		var d: Dictionary = g.doors[p]
		var horizontal: bool = g.kind(p + Vector2i(0, -1)) == "wall"
		var size := Vector3(0.2, 2.4, 1) if horizontal else Vector3(1, 2.4, 0.2)
		var off := Vector3(0, 0, 0.9) if (horizontal and d.open) else (Vector3(0.9, 0, 0) if d.open else Vector3.ZERO)
		var col: Color = th.accent.darkened(0.2) if not d.get("locked", false) else Color(0.8, 0.1, 0.1)
		box(parent, Vector3(p.x, 1.2, p.y) + off, size, col, 0.2)

## A small set for dialogue scenes.
static func build_set(parent: Node3D, location: String) -> void:
	var th := theme(location)
	match location:
		"lowlight_street":
			for x in range(-6, 7):
				for z in range(-3, 5):
					box(parent, Vector3(x, -0.05, z), Vector3(1, 0.1, 1), th.floor if (x + z) % 2 == 0 else th.floor2)
			box(parent, Vector3(0, 4, -3.5), Vector3(14, 8, 1), th.wall)
			# The Galactic C, nose-first in the wall, three storeys up.
			box(parent, Vector3(1.5, 5.5, -2.2), Vector3(3.5, 1.4, 2.2), Color(0.85, 0.85, 0.9))
			box(parent, Vector3(1.5, 5.5, -1.0), Vector3(1.8, 0.8, 0.6), Color(0.2, 0.9, 0.9), 0.8)
			box(parent, Vector3(-4, 3.5, -2.95), Vector3(2.5, 0.6, 0.1), Color(1.0, 0.25, 0.7), 2.0)
			box(parent, Vector3(5, 2.2, -2.95), Vector3(1.6, 1.2, 0.1), Color(0.2, 0.9, 1.0), 2.0)
			box(parent, Vector3(-1, 1.1, -2.95), Vector3(1.2, 2.2, 0.1), Color(0.35, 0.3, 0.25))
		_:
			for x in range(-5, 6):
				for z in range(-3, 4):
					box(parent, Vector3(x, -0.05, z), Vector3(1, 0.1, 1), th.floor if (x + z) % 2 == 0 else th.floor2)
			# Back wall with a window hole: the planet hangs outside.
			var win_w := 7.0 if location == "galactic_c_cockpit" else 2.4
			var side := (11.0 - win_w) / 2.0
			box(parent, Vector3(-5.5 + side / 2.0, 2.5, -3.5), Vector3(side, 5, 0.5), th.wall)
			box(parent, Vector3(5.5 - side / 2.0, 2.5, -3.5), Vector3(side, 5, 0.5), th.wall)
			box(parent, Vector3(0, 0.45, -3.5), Vector3(win_w, 0.9, 0.5), th.wall)
			box(parent, Vector3(0, 3.75, -3.5), Vector3(win_w, 2.5, 0.5), th.wall)
			box(parent, Vector3(0, 0.92, -3.25), Vector3(win_w, 0.06, 0.1), th.accent, 0.8)
			box(parent, Vector3(-5.5, 2.5, 0), Vector3(0.5, 5, 7), th.wall)
			box(parent, Vector3(5.5, 2.5, 0), Vector3(0.5, 5, 7), th.wall)
			box(parent, Vector3(0, 5.1, 0), Vector3(11.5, 0.2, 7.5), th.wall.darkened(0.4))
			box(parent, Vector3(0, 1.7, -30), Vector3(60, 40, 0.5), Color(0.01, 0.0, 0.04))
			sphere(parent, Vector3(1.5, 0.2, -14), 5.5 if location == "galactic_c_cockpit" else 4.0, Color(0.55, 0.15, 0.75), 0.9)
			for i in 14:
				sphere(parent, Vector3(-8 + i * 1.3, 1.0 + (i * 37 % 7) * 0.5, -20), 0.06, Color(1, 1, 1), 3.0)
			sphere(parent, Vector3(-2.0, 2.4, -12), 0.3, Color(0.3, 0.9, 1.0), 2.0)
			if location == "galactic_c_workshop":
				box(parent, Vector3(-3, 0.5, -2), Vector3(2, 1, 1), th.furniture)
				box(parent, Vector3(3.5, 1.3, -3.1), Vector3(1, 1.4, 0.3), th.accent, 0.8)
			elif location == "galactic_c_cockpit":
				box(parent, Vector3(0, 0.5, -2.2), Vector3(5, 1, 1), th.furniture)
				for i in 6:
					box(parent, Vector3(-2 + i * 0.8, 1.02, -2.2), Vector3(0.3, 0.04, 0.3), [Color(1, 0.2, 0.2), Color(0.2, 1, 0.4), Color(1, 0.8, 0.2)][i % 3], 2.0)
