## A combatant, civilian or fragile object. Pure data + derived stats (bible 03 §3.2).
## No scene-tree dependency.
extends RefCounted

const TEAM_PARTY := "party"
const TEAM_ENEMY := "enemy"
const TEAM_CIVILIAN := "civilian"
const TEAM_OBJECT := "object"

var id: String
var name: String
var team: String
var role: String = "brute"          # AI role: brute, skirmisher, marksman, leader, support
var temperament: String = "opportunist"
var level: int = 1
var attrs := {"might": 10, "grace": 10, "vigor": 10, "perception": 10, "resolve": 10, "eternity": 10}

var max_hp: int
var hp: int
var max_focus: int
var focus: float
var max_poise: int
var poise: int
var speed: float
var move: int = 6
var defense: int = 0                 # percent reduction, capped at 60

var pos := Vector2i.ZERO
var facing := Vector2i(0, 1)
var height_bonus := 0

## weapon: {kind: "melee"|"ranged", reach, range, min, max, accuracy, aoe (bool), noise}
var weapon := {"kind": "melee", "reach": 1, "range": 1, "min": 6, "max": 10, "accuracy": 80}
var abilities: Array = []           # e.g. ["pass_turn", "shove", "search"]
var cooldowns := {}                 # ability -> own turns remaining
var statuses := {}                  # status -> own turns remaining (-1 = until cleared)

var shield := 0                     # personal shield HP
var deflector := false              # reflects ranged/AoE aimed within 2 tiles
var reaction_available := true
var downed_turns := -1              # party only; >=0 while Downed
var downed_limit := 3               # turns at 0 HP before dying (Taz: 8)
var drug_chance := 25.0             # combat drugs: % chance of an extra action per turn
var charges := {}                   # per-fight uses, e.g. {"stun_grenade": 1}
var locked: Array = []              # abilities shown but locked this fight (tutorial)
var shield_power := 60
var voice := ""                     # dialogue speaker id
var out := false                    # Out for the fight
var dead := false
var hidden := false                 # objects revealed by Search
var fragile := false
var on_destroy := {}                # {"explode": n} or {"disable_deflector": unit_id}
var essential := false              # main character: death = game over
var protect := false                # collateral: losing it fails/penalises the fight
var name_short := ""

static func from_dict(d: Dictionary) -> RefCounted:
	var u = load("res://engine/unit.gd").new()
	u.id = d.get("id", "unit")
	u.name = d.get("name", u.id)
	u.name_short = d.get("glyph", u.name.substr(0, 1))
	u.team = d.get("team", TEAM_ENEMY)
	u.role = d.get("role", "brute")
	u.temperament = d.get("temperament", "opportunist")
	u.level = int(d.get("level", 1))
	for k in d.get("attrs", {}).keys():
		u.attrs[k] = int(d["attrs"][k])
	if d.has("weapon"):
		u.weapon = d["weapon"].duplicate(true)
	u.abilities = d.get("abilities", []).duplicate()
	u.deflector = bool(d.get("deflector", false))
	u.shield = int(d.get("shield", 0))
	u.defense = int(d.get("defense", 0))
	u.hidden = bool(d.get("hidden", false))
	u.fragile = bool(d.get("fragile", false))
	u.on_destroy = d.get("on_destroy", {}).duplicate(true)
	u.essential = bool(d.get("essential", false))
	u.downed_limit = int(d.get("downed_limit", 3))
	u.drug_chance = float(d.get("drug_chance", 25.0))
	u.charges = d.get("charges", {}).duplicate()
	u.locked = d.get("locked", []).duplicate()
	u.shield_power = int(d.get("shield_power", 60))
	if d.get("unnoticed", false):
		u.statuses["unnoticed"] = -1
	u.protect = bool(d.get("protect", false))
	if d.has("pos"):
		u.pos = Vector2i(int(d["pos"][0]), int(d["pos"][1]))
	if d.has("facing"):
		u.facing = Vector2i(int(d["facing"][0]), int(d["facing"][1]))
	u.recompute()
	if d.has("hp"):
		u.max_hp = int(d["hp"])
	u.hp = u.max_hp
	u.focus = u.max_focus
	u.poise = u.max_poise
	if d.has("speed"):
		u.speed = float(d["speed"])
	if d.has("move"):
		u.move = int(d["move"])
	return u

## Bible 03 §3.2.
func recompute() -> void:
	max_hp = 40 + attrs.vigor * 6 + level * 8
	max_focus = int(10 + attrs.resolve * 1.5)
	max_poise = 20 + attrs.vigor * 2
	speed = 100.0 + attrs.grace * 1.5 + attrs.perception * 1.0
	defense = mini(defense, 60)

func focus_regen() -> float:
	return 2.0 + attrs.eternity / 10.0

func is_object() -> bool:
	return team == TEAM_OBJECT

func can_act() -> bool:
	return not dead and not out and downed_turns < 0 and team != TEAM_OBJECT and team != TEAM_CIVILIAN

func is_targetable() -> bool:
	return not dead and not out and not hidden

func is_active() -> bool:
	return not dead and not out

func has_status(s: String) -> bool:
	return statuses.has(s)

func add_status(s: String, turns: int) -> void:
	statuses[s] = turns

func max_reactions() -> int:
	return 2 if attrs.resolve >= 20 else 1

func to_dict() -> Dictionary:
	return {
		"id": id, "name": name, "team": team, "level": level,
		"hp": hp, "max_hp": max_hp, "focus": snappedf(focus, 0.1), "max_focus": max_focus,
		"poise": poise, "max_poise": max_poise, "shield": shield,
		"speed": speed, "move": move, "pos": [pos.x, pos.y], "facing": [facing.x, facing.y],
		"weapon": weapon, "abilities": abilities, "cooldowns": cooldowns,
		"statuses": statuses, "charges": charges, "locked": locked, "deflector": deflector, "downed": downed_turns >= 0,
		"out": out, "dead": dead, "fragile": fragile, "protect": protect,
	}
