## DOTS over stdio: one JSON request per line in, one JSON response per line out.
##   godot --headless --path . --script agent/dots_stdio.gd
## Example: {"cmd":"load","arena":"deflector","seed":1}
extends SceneTree

const Session = preload("res://agent/dots_session.gd")

func _init() -> void:
	var s = Session.new()
	print(JSON.stringify({"ok": true, "hello": "Dust of the Sun DOTS agent API", "commands": s.handle({"cmd": "help"}).commands}))
	while true:
		var line := OS.read_string_from_stdin().strip_edges()
		if line == "":
			break  # EOF (or a blank line) ends the session
		var req = JSON.parse_string(line)
		if typeof(req) != TYPE_DICTIONARY:
			print(JSON.stringify({"ok": false, "error": "Send one JSON object per line."}))
			continue
		if req.get("cmd", "") == "quit":
			break
		print(JSON.stringify(s.handle(req)))
	quit()
