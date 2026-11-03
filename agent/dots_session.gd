## The DOTS agent API (bible 03 §11) as a transport-free session object.
## Transports (stdio now, WebSocket later) just pass JSON dictionaries in and out.
extends RefCounted

const Data = preload("res://engine/data.gd")
const AI = preload("res://engine/ai.gd")

var combat = null
var controlled_team := "party"

func handle(req: Dictionary) -> Dictionary:
	var cmd: String = req.get("cmd", "")
	match cmd:
		"arenas":
			return {"ok": true, "arenas": Data.arena_ids()}
		"load":
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
		"map":
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
			return {"ok": true, "commands": ["arenas", "load {arena, seed, difficulty}", "state", "map", "act {id}", "auto", "quit"]}
	return {"ok": false, "error": "Unknown command '%s'. Try {\"cmd\":\"help\"}." % cmd}

## Runs AI turns for everything the agent doesn't control, until it's the agent's turn or the fight ends.
func _run_others() -> Array:
	var before: int = combat.narration.size()
	var guard := 0
	while combat.outcome == "" and combat.current() != null and combat.current().team != controlled_team and guard < 200:
		AI.take_turn(combat)
		guard += 1
	return combat.narration.slice(before)

func _with_state(r: Dictionary) -> Dictionary:
	if combat != null:
		r["state"] = combat.state()
	return r
