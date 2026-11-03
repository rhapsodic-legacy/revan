## Deterministic RNG. Same seed + same inputs = same game (bible 03 §11).
extends RefCounted

var _rng := RandomNumberGenerator.new()

func _init(seed_value: int = 1) -> void:
	_rng.seed = seed_value

func randi_range(a: int, b: int) -> int:
	return _rng.randi_range(a, b)

## Percent roll: true with probability pct/100.
func chance(pct: float) -> bool:
	return _rng.randf() * 100.0 < pct

func randf() -> float:
	return _rng.randf()

func get_state() -> int:
	return _rng.state

func set_state(s: int) -> void:
	_rng.state = s
