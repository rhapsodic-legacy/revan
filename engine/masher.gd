## A deliberately naive player for balance tests: attacks whatever is in reach (cannon included,
## ignoring Deflector warnings), otherwise walks at the nearest enemy. Never Searches, never uses doors.
extends RefCounted

const Grid = preload("res://engine/grid.gd")
const AI = preload("res://engine/ai.gd")

static func take_turn(c) -> void:
	var u = c.current()
	if u.team != "party":
		AI.take_turn(c)
		return
	for pass_ in 2:
		if c.current_id != u.id:
			return
		var legal: Array = c.legal_actions()
		var foes := {}
		for h in c.hostiles_of(u):
			foes[h.id] = h.pos
		var atk := legal.filter(func(a): return (a.type == "attack" and foes.has(a.target)) \
			or (a.type == "cannon" and Vector2i(a.center[0], a.center[1]) in foes.values()))
		if not atk.is_empty():
			c.act(atk[0].id)
			break
		if pass_ == 0:
			var hs: Array = c.hostiles_of(u)
			if hs.is_empty():
				break
			var best = null
			var bd := 999
			for a in legal:
				if a.type != "move":
					continue
				for h in hs:
					var d := Grid.cheb(Vector2i(a.to[0], a.to[1]), h.pos)
					if d < bd:
						bd = d
						best = a
			if best != null:
				c.act(best.id)
	if c.current_id == u.id:
		c.act("end")

static func autoplay(c, max_steps := 600) -> String:
	if c.current_id == "" and c.outcome == "":
		c.start()
	var n := 0
	while c.outcome == "" and n < max_steps:
		take_turn(c)
		n += 1
	return c.outcome if c.outcome != "" else "draw"
