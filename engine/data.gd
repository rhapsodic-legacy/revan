## Loads characters and arenas from /data (JSON, diffable, AI-authorable).
extends RefCounted

const Combat = preload("res://engine/combat.gd")

static func load_json(path: String):
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Cannot open %s" % path)
		return null
	return JSON.parse_string(f.get_as_text())

static func characters() -> Dictionary:
	return load_json("res://data/characters.json")

static func arena_ids() -> Array:
	var ids := []
	var dir := DirAccess.open("res://data/arenas")
	for f in dir.get_files():
		if f.ends_with(".json"):
			ids.append(f.get_basename())
	ids.sort()
	return ids

## Resolves "template" references and returns arena data ready for Combat.from_arena.
static func arena(id: String) -> Dictionary:
	var d: Dictionary = load_json("res://data/arenas/%s.json" % id)
	var chars := characters()
	var units := []
	for ud in d["units"]:
		var merged := {}
		if ud.has("template"):
			merged = chars[ud["template"]].duplicate(true)
		for k in ud.keys():
			merged[k] = ud[k]
		units.append(merged)
	d["units"] = units
	return d

static func new_combat(id: String, seed_value := 1) -> RefCounted:
	return Combat.from_arena(arena(id), seed_value)
