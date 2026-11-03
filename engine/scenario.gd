## Scenario runner: plays a Scenario Spec (bible 05 §0) as data. Scenes, dialogue lines by ID,
## choices with flag effects, fights with tutorial prompts and barks, walks, Altitude, loot, ratings.
## Headless; the UI and the DOTS agent API both drive it through legal_actions() / act().
extends RefCounted

const Data = preload("res://engine/data.gd")
const Combat = preload("res://engine/combat.gd")
const AI = preload("res://engine/ai.gd")

var spec: Dictionary
var lines: Dictionary
var seed_value := 1
var step_index := -1
var queue: Array = []               # pending beats of the current step
var mode := "dialogue"              # dialogue | choice | combat | defeat | end
var current_beat := {}              # what's on screen: {speaker, text, dir, subtitle} or {narrate}
var choice: Array = []              # options while mode == "choice"
var flags := {}
var altitude := -1                  # -1 until the meter appears
var combat = null
var fight_step := {}
var attempts := 0
var fired_barks := {}
var bark_log: Array = []
var ratings := {}
var transcript: Array = []          # everything shown, in order (for logs and agents)
var events_seen := 0
var difficulty := "seer"
var combat_last = null
var auto_enemies := true            # run non-party turns with the AI right away
var stage := {}                     # scene staging for the view: {"extras": [...], "stand": "deena"}
const AFFECTION_NAMES := {"ashe": "Ashe", "dust": "Dust", "deena": "Deena", "statda": "Statda", "ksaabu": "K'saabu"}

static func load_id(id: String, seed_v := 1) -> RefCounted:
	var s = load("res://engine/scenario.gd").new()
	s.spec = Data.load_json("res://data/scenarios/%s.json" % id)
	s.lines = Data.load_json(s.spec.get("lines_file", "res://data/scenarios/%s_lines.json" % id))
	s.seed_value = seed_v
	s._next_step()
	return s

# ------------------------------------------------------------------ flow

func step():
	return spec.steps[step_index] if step_index >= 0 and step_index < spec.steps.size() else {}

func _next_step() -> void:
	step_index += 1
	if step_index >= spec.steps.size():
		mode = "end"
		current_beat = {"narrate": "End of %s." % spec.get("title", spec.id)}
		return
	var st: Dictionary = step()
	queue = st.get("beats", []).duplicate(true)
	match st.type:
		"walk":
			if altitude >= 0:
				altitude = maxi(0, altitude + int(st.get("altitude", 0)))
		"fight":
			fight_step = st
			attempts = 0
			fired_barks = {}
			queue = st.get("intro", []).duplicate(true)
			queue.append({"start_fight": true})
	_advance_beat()

func _advance_beat() -> void:
	while true:
		if queue.is_empty():
			if mode == "combat":
				return
			_next_step()
			return
		var b: Dictionary = queue.pop_front()
		if b.has("line"):
			var l: Dictionary = lines.get(b.line, {"speaker": "?", "text": "[missing line %s]" % b.line})
			current_beat = {"id": b.line, "speaker": l.get("speaker", ""), "text": l.get("text", ""),
				"dir": l.get("dir", ""), "subtitle": l.get("subtitle", "")}
			_record(current_beat)
			mode = "dialogue"
			return
		if b.has("narrate"):
			current_beat = {"narrate": b.narrate}
			_record(current_beat)
			mode = "dialogue"
			return
		if b.has("tip"):
			current_beat = {"tip": b.tip}
			_record({"narrate": "TIP: " + b.tip})
			mode = "dialogue"
			return
		if b.has("stage"):
			for k in b.stage.keys():
				stage[k] = b.stage[k]
			continue
		if b.has("choice"):
			choice = _available(b.choice)
			if choice.is_empty():
				continue
			mode = "choice"
			current_beat = {"narrate": "Choose.", "prompt": b.get("prompt", "")}
			return
		if b.has("altitude"):
			altitude = int(b.altitude)
			continue
		if b.has("set"):
			for k in b.set.keys():
				flags[k] = b.set[k]
			continue
		if b.has("loot"):
			current_beat = {"narrate": "Loot: %s. Battle ratings: %s." % [", ".join(b.loot), _ratings_text()]}
			flags["loot"] = b.loot
			_record(current_beat)
			mode = "dialogue"
			return
		if b.has("landing"):
			var clean := altitude > 2000
			flags["op.landing"] = "clean" if clean else "rough"
			current_beat = {"narrate": ("ALTITUDE %s m. Ashe makes the chair with height to spare: a clean crash. Bonus credits." if clean
				else "ALTITUDE %s m. Ashe makes the chair, barely: a rough crash. The crew start Act I bruised (-15%% HP).") % _fmt(altitude)}
			_record(current_beat)
			mode = "dialogue"
			return
		if b.has("start_fight"):
			_start_fight()
			return

## Options the player can see right now: conditional ones are filtered, stat-gated ones are labelled.
func _available(opts: Array) -> Array:
	var out := []
	var chars: Dictionary = Data.characters()
	for o in opts:
		if o.has("if"):
			if flags.get(o["if"][0]) != o["if"][1]:
				continue
		var opt: Dictionary = o.duplicate(true)
		if o.has("req") and not o.has("met"):
			var r: Dictionary = o.req
			var who: Dictionary = chars.get(r.get("who", "op_dust"), {})
			var have: int = int(who.get("attrs", {}).get(r.attr, 0))
			opt["special"] = true
			opt["met"] = have >= int(r.min)
			opt["text"] = "[%s %d] %s" % [String(r.attr).capitalize(), int(r.min), o.text]
			if not opt.met:
				continue
		out.append(opt)
	return out

func _record(b: Dictionary) -> void:
	if b.has("narrate"):
		transcript.append(b.narrate)
	else:
		var t: String = "%s: \"%s\"" % [b.speaker, b.text]
		if b.subtitle != "":
			t += " (%s)" % b.subtitle
		transcript.append(t)

# ------------------------------------------------------------------ fights

func _start_fight() -> void:
	attempts += 1
	combat = Data.new_combat(fight_step.arena, seed_value * 100 + attempts)
	combat.difficulty = difficulty
	var fm: Dictionary = fight_step.get("first_if", {})
	if not fm.is_empty() and flags.get(fm.flag, false):
		combat.first_mover = fm.unit
	events_seen = 0
	fired_barks = {}
	mode = "combat"
	current_beat = {}
	combat.start()
	for p in fight_step.get("prompts", []):
		combat.say("TIP: " + p)
	_after_combat_action()

func fight_altitude() -> int:
	if altitude < 0:
		return -1
	if combat == null or mode != "combat":
		return altitude
	return maxi(0, altitude - combat.rounds_elapsed() * int(spec.get("altitude_per_round", 300)))

## Called after every combat action: barks, flags, enemy turns, and the end of the fight.
func _after_combat_action() -> void:
	_scan()
	if auto_enemies:
		var guard := 0
		while combat != null and mode == "combat" and combat.outcome == "" and combat.current() != null \
				and combat.current().team != "party" and guard < 200:
			AI.take_turn(combat)
			_scan()
			guard += 1

func _scan() -> void:
	if combat == null or mode != "combat":
		return
	var evs: Array = combat.events
	while events_seen < evs.size():
		_check_barks(evs[events_seen])
		events_seen += 1
	_check_cut_off()
	if combat.outcome == "victory":
		_finish_fight()
	elif combat.outcome != "":
		mode = "defeat"
		current_beat = {"narrate": "Defeat. " + _fail_hint()}
		_record(current_beat)

func _check_barks(e: Dictionary) -> void:
	for i in fight_step.get("barks", []).size():
		var r: Dictionary = fight_step.barks[i]
		if fired_barks.has(i) or r.on != e.type:
			continue
		var ok := true
		for k in ["team", "target", "id"]:
			if r.has(k) and e.get(k, null) != r[k]:
				ok = false
		if r.has("by"):
			var by_val = e.get("by", "")
			var who = combat.by_id.get(by_val)
			if by_val != r.by and (who == null or who.name != r.by):
				ok = false
		if ok:
			_fire(i, r)

func _check_cut_off() -> void:
	for i in fight_step.get("barks", []).size():
		var r: Dictionary = fight_step.barks[i]
		if r.on != "cut_off" or fired_barks.has(i):
			continue
		var u = combat.by_id.get(r.unit)
		var dp := Vector2i(int(r.door[0]), int(r.door[1]))
		if u != null and u.is_active() and u.pos.x > int(r.beyond_x) and combat.grid.door_closed(dp) \
				and combat.units.any(func(o): return o.team == "enemy" and o.is_active() and o.pos.x < int(r.beyond_x)):
			_fire(i, r)

func _fire(i: int, r: Dictionary) -> void:
	fired_barks[i] = true
	if r.get("line") != null and lines.has(r.line):
		var l: Dictionary = lines[r.line]
		var t := "%s: \"%s\"" % [l.speaker, l.text]
		if l.has("subtitle"):
			t += " (%s)" % l.subtitle
		combat.say(t)
		bark_log.append(r.line)
	if r.has("flag") and not flags.has(r.flag[0]):
		flags[r.flag[0]] = r.flag[1]
	if r.has("effect") and r.effect.has("status"):
		var s: Array = r.effect.status
		var u = combat.by_id.get(s[0])
		if u != null and u.can_act():
			u.add_status(s[1], int(s[2]))

func _fail_hint() -> String:
	var hints: Dictionary = fight_step.get("fail_hints", {})
	if hints.has("reflected") and combat.narration.any(func(l): return "rebounds" in l):
		return hints.reflected
	if hints.has("deena") and combat.by_id.has("deena") and combat.by_id["deena"].downed_turns >= 0:
		return hints.deena
	return "Retry from the start of the fight."

func _finish_fight() -> void:
	if fight_step.has("default_flag") and not flags.has(fight_step.default_flag[0]):
		flags[fight_step.default_flag[0]] = fight_step.default_flag[1]
	ratings[fight_step.id] = _rate()
	if altitude >= 0:
		altitude = fight_altitude()
	mode = "dialogue"
	var outro: Array = fight_step.get("outro", []).duplicate(true)
	queue = [{"narrate": "%s won in %d round(s). Rating: %s. ALTITUDE %s m." % [fight_step.title, combat.rounds_elapsed(), ratings[fight_step.id], _fmt(altitude)]}] + outro
	combat_last = combat
	combat = null
	_advance_beat()


## Battle rating D–S (bible 05 §8): rounds, damage taken, Insights found, Style.
func _rate() -> String:
	var taken := 0
	var style := 0
	for e in combat.events:
		if e.type == "hit" and combat.by_id.has(e.target) and combat.by_id[e.target].team == "party":
			taken += int(e.amount)
		if e.type in ["use", "deflector_down", "grenade", "shove"]:
			style += 1
	var found: int = combat.insights.filter(func(i): return i.found).size()
	var score: float = 100.0 - combat.rounds_elapsed() * 3.0 - taken / 6.0 + found * 6.0 + mini(style, 3) * 6.0
	if score >= 90: return "S"
	if score >= 75: return "A"
	if score >= 60: return "B"
	if score >= 45: return "C"
	return "D"

func _ratings_text() -> String:
	var parts := []
	for k in ratings.keys():
		parts.append("%s %s" % [k, ratings[k]])
	return ", ".join(parts) if not parts.is_empty() else "none"

static func _fmt(n: int) -> String:
	var s := str(n)
	return s.substr(0, s.length() - 3) + "," + s.substr(s.length() - 3) if s.length() > 3 else s

## Test helper: win the current fight instantly (used to reach later fights in tests).
func _scenario_skip_fight() -> void:
	for u in combat.units:
		if u.team == "enemy":
			u.dead = true
	combat._check_outcome()
	_after_combat_action()

# ------------------------------------------------------------------ the API

func legal_actions() -> Array:
	match mode:
		"dialogue":
			return [{"id": "next", "type": "next"}]
		"choice":
			var out := []
			for i in choice.size():
				out.append({"id": "choose:%d" % i, "type": "choose", "text": choice[i].text})
			return out
		"combat":
			return combat.legal_actions()
		"defeat":
			return [{"id": "retry", "type": "retry"}]
	return []

func act(id: String) -> Dictionary:
	var before := transcript.size()
	match mode:
		"dialogue":
			if id != "next":
				return {"ok": false, "error": "In dialogue, the only action is 'next'."}
			_advance_beat()
		"choice":
			if not id.begins_with("choose:"):
				return {"ok": false, "error": "Pick an option with 'choose:<n>'."}
			var n := int(id.substr(7))
			if n < 0 or n >= choice.size():
				return {"ok": false, "error": "No option %d." % n}
			var opt: Dictionary = choice[n]
			transcript.append("> " + opt.text)
			for k in opt.get("effects", {}).keys():
				var v = opt.effects[k]
				if typeof(v) == TYPE_BOOL:
					flags[k] = v
				else:
					flags[k] = flags.get(k, 0) + v
			var follow: Array = opt.get("beats", []).duplicate(true)
			var hearts := []
			for k in opt.get("effects", {}).keys():
				if String(k).begins_with("affection."):
					var who := String(k).substr(10)
					hearts.append("♥ %s %+d" % [AFFECTION_NAMES.get(who, who), int(opt.effects[k])])
			if not hearts.is_empty():
				var at := 0
				while at < follow.size() and (follow[at].has("set") or follow[at].has("stage")):
					at += 1
				follow.insert(at, {"narrate": "Affection:  " + "     ".join(hearts)})
			if opt.get("repeat", false):
				var remaining := []
				for j in choice.size():
					if j != n:
						remaining.append(choice[j])
				follow.append({"choice": remaining})
			queue = follow + queue
			_advance_beat()
		"combat":
			var cid: String = combat.current_id
			var r: Dictionary = combat.act(id)
			if not r.ok:
				return r
			_after_combat_action()
			return {"ok": true, "log": r.log}
		"defeat":
			if id != "retry":
				return {"ok": false, "error": "Send 'retry' to restart the fight."}
			_start_fight()
		_:
			return {"ok": false, "error": "The scenario is over."}
	return {"ok": true, "log": transcript.slice(before)}

func state() -> Dictionary:
	var st: Dictionary = step()
	var s := {
		"mode": mode,
		"scenario": spec.id,
		"step": {"id": st.get("id", ""), "title": st.get("title", ""), "type": st.get("type", ""), "location": st.get("location", ""), "setting": st.get("setting", "")},
		"altitude": fight_altitude(),
		"flags": flags,
		"ratings": ratings,
	}
	if mode == "combat":
		var cs: Dictionary = combat.state()
		cs["prompts"] = fight_step.get("prompts", [])
		cs.erase("mode")
		s["combat"] = cs
		s["legalActions"] = cs.legalActions
		cs.erase("legalActions")
	else:
		s["beat"] = current_beat
		if mode == "choice":
			s["options"] = choice.map(func(o): return o.text)
			if current_beat.get("prompt", "") != "":
				s["prompt"] = current_beat.prompt
		s["legalActions"] = legal_actions()
	s["log"] = (combat.narration.slice(maxi(0, combat.narration.size() - 12)) if mode == "combat" else transcript.slice(maxi(0, transcript.size() - 6)))
	return s
