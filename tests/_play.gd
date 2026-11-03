extends SceneTree
const Session = preload("res://agent/dots_session.gd")
func _init():
	var s = Session.new()
	var r = s.handle({"cmd": "play", "scenario": "opening", "seed": int(OS.get_environment("SEED") if OS.get_environment("SEED") != "" else "1")})
	var n := 0
	while r.state.mode != "end" and n < 1500:
		r = s.handle({"cmd": "auto"})
		n += 1
		for l in r.get("log", []):
			print(l)
	print("ACTIONS ", n, " FLAGS ", r.state.flags, " RATINGS ", r.state.ratings, " ALT ", r.state.altitude)
	quit()
