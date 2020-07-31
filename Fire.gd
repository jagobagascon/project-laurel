tool
extends Spatial

const MAX_LIGHT: float = 1.0
const MIN_LIGHT: float = 0.6
var cur_light
func _process(delta):
	if (OS.get_ticks_msec() / 200) % 2 == 0:
		$Light.light_energy = max(MIN_LIGHT, min(MAX_LIGHT, (randf() + randf() + randf()) / 3.0))
