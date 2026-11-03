## The DOTS agent API (bible 03 §11) as a transport-free session object.
## Transports (stdio now, WebSocket later) just pass JSON dictionaries in and out.
extends RefCounted

const Data = preload("res://engine/data.gd")
const AI = preload("res://engine/ai.gd")
const Scenario = preload("res://engine/scenario.gd")

var combat = null
var scenario = null
var controlled_team := "party"

func handle(req: Dictionary) -> Dictionary:
	var cmd: String = req.get("cmd", "")
	match cmd:
		"arenas":
			return {"ok": true, "arenas": Data.arena_ids()}
		"scenarios":
			var ids := []
			for f in DirAccess.open("res://data/scenarios").get_files():
				if f.ends_with(".json") and not f.ends_with("_lines.json"):
					ids.append(f.get_basename())
			return {"ok": true, "scenarios": ids}
		"play":
			scenario = Scenario.load_id(req.get("scenario", "opening"), int(req.get("seed", 1)))
			if req.has("difficulty"):
				scenario.difficulty = req["difficulty"]
			combat = null
			return _with_state({"ok": true, "log": scenario.transcript.duplicate()})
		"load":
			scenario = null
			var id: String = req.get("arena", "")
			if not id in Data.arena_ids():
				return {"ok": false, "error": "Unknown arena '%s'." % id}
			combat = Data.new_combat(id, int(req.get("seed", 1)))
			if req.has("difficulty"):
				combat.difficulty = req["difficulty"]
			combat.start()
			var log0: Array = combat.narration.duplicate()
			log0.append_array(_run_others())
			return _with_state({"ok": true, "log": log0})
		"state":
			return _with_state({"ok": true})
		"act" when scenario != null:
			var r0: Dictionary = scenario.act(req.get("id", ""))
			return _with_state(r0)
		"auto" when scenario != null:
			return _with_state(_scenario_auto())
		"map":
			if scenario != null:
				if scenario.mode != "combat":
					return {"ok": false, "error": "No fight on right now."}
				return {"ok": true, "map": scenario.combat.describe_map()}
			if combat == null:
				return {"ok": false, "error": "No arena loaded."}
			return {"ok": true, "map": combat.describe_map()}
		"act":
			if combat == null:
				return {"ok": false, "error": "No arena loaded."}
			var r: Dictionary = combat.act(req.get("id", ""))
			if r.ok:
				r.log.append_array(_run_others())
			return _with_state(r)
		"auto":
			## Standing Orders: let the built-in AI play the current party turn.
			if combat == null or combat.outcome != "":
				return {"ok": false, "error": "Nothing to play."}
			var before: int = combat.narration.size()
			var taken := AI.take_turn(combat)
			_run_others()
			return _with_state({"ok": true, "taken": taken, "log": combat.narration.slice(before)})
		"help":
			return {"ok": true, "commands": ["scenarios", "play {scenario, seed, difficulty}", "arenas", "load {arena, seed, difficulty}", "state", "map", "act {id}", "auto", "quit"]}
	return {"ok": false, "error": "Unknown command '%s'. Try {\"cmd\":\"help\"}." % cmd}

## Runs AI turns for everything the agent doesn't control, until it's the agent's turn or the fight ends.
func _run_others() -> Array:
	var before: int = combat.narration.size()
	var guard := 0
	while combat.outcome == "" and combat.current() != null and combat.current().team != controlled_team and guard < 200:
		AI.take_turn(combat)
		guard += 1
	return combat.narration.slice(before)

## Standing Orders for a scenario: AI plays the party turn; dialogue advances; first option picked.
func _scenario_auto() -> Dictionary:
	var before: int = scenario.transcript.size()
	match scenario.mode:
		"combat":
			var c = scenario.combat
			var n0: int = c.narration.size()
			AI.take_turn(c)
			var log: Array = c.narration.slice(n0)
			scenario._after_combat_action()
			if scenario.combat != null:
				log = c.narration.slice(n0)
			return {"ok": true, "log": log}
		"dialogue":
			return scenario.act("next")
		"choice":
			return scenario.act("choose:0")
		"defeat":
			return scenario.act("retry")
	return {"ok": false, "error": "Nothing to play."}

func _with_state(r: Dictionary) -> Dictionary:
	if scenario != null:
		r["state"] = scenario.state()
		return r
	if combat != null:
		r["state"] = combat.state()
	return r
