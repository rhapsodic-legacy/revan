## Base for unit tests.
extends RefCounted

var failed := false
var message := ""
var runner

func check(cond: bool, msg: String) -> void:
	if not cond and not failed:
		failed = true
		message = msg

func eq(a, b, msg: String) -> void:
	check(a == b, "%s (got %s, expected %s)" % [msg, str(a), str(b)])
