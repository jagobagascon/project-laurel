tool
extends Spatial

export var on: bool = false

var a: Timer = Timer.new()

func _ready():
	pass # Replace with function body.

func _process(delta):
	if on:
		var l = get_children()[0] as Light
		l.light_energy = _randomize(1, l.light_energy)

func _randomize(mx: float, def: float) -> float:
	var max_change = 1.0
	var probability = randf()
	var light_change = randf()
	if probability < .06:
		return max(0.0, def - max_change * light_change)
	elif probability > .94:
		return min(1.0, def + max_change * light_change)
	return def

func on():
	on = true
	for c in get_children():
		(c as Light).light_energy = 1

func off():
	on = false
	for c in get_children():
		(c as Light).light_energy = 0

