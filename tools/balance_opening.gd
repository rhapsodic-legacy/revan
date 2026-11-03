## Balance report: godot --headless --path . --script tools/balance_opening.gd
extends SceneTree
const Data = preload("res://engine/data.gd")
const AI = preload("res://engine/ai.gd")
const Masher = preload("res://engine/masher.gd")
func _init():
	for id in ["op_f1_lounge","op_f2_hall","op_f3_bay"]:
		var res := {}
		var rounds := 0
		for s in range(1, 21):
			var c = Data.new_combat(id, s)
			var r = AI.autoplay(c)
			res[r] = res.get(r, 0) + 1
			rounds += c.rounds_elapsed()
		print(id, " ", res, " avg rounds ", rounds/20.0)
	for id in ["op_f1_lounge","op_f2_hall","op_f3_bay"]:
		var res := {}
		for s in range(1, 21):
			var c = Data.new_combat(id, s)
			var r = Masher.autoplay(c)
			res[r] = res.get(r, 0) + 1
		print("MASHER ", id, " ", res)
	quit()
