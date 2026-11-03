## Headless test runner: godot --headless --path . --script tests/run_tests.gd
## Runs every test_* method in tests/unit/*.gd. Exit code 1 on any failure.
## (Lightweight stand-in for GUT so CI needs nothing but the Godot binary.)
extends SceneTree

var failures := 0
var passes := 0

func _init() -> void:
	var dir := DirAccess.open("res://tests/unit")
	var files := Array(dir.get_files()).filter(func(f): return f.ends_with(".gd"))
	files.sort()
	for f in files:
		var script = load("res://tests/unit/" + f)
		for m in script.get_script_method_list():
			var mname: String = m.name
			if not mname.begins_with("test_"):
				continue
			var inst = script.new()
			inst.set("runner", self)
			inst.call(mname)
			if inst.get("failed"):
				failures += 1
				print("FAIL %s::%s  %s" % [f, mname, inst.get("message")])
			else:
				passes += 1
				print("ok   %s::%s" % [f, mname])
	print("\n%d passed, %d failed" % [passes, failures])
	quit(1 if failures > 0 else 0)
