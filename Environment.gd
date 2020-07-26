extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const day = 24 * 60 * 60 * 1000

const day_start: float = 6.0 / 24.0
const day_end: float = 18.0 / 24.0

const day_duration: float = day_end - day_start
const dawn_duration: float = 0.5 / 24.0
const dusk_duration: float = 0.5 / 24.0

const MAX_ENERGY = 1.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	var offset = _get_offset_from_cur_time()
	$SunPos.rotation_degrees.z = 180.0 - offset * 360.0
	$SunPos/Sun.light_energy = _get_energy_from_offset(offset)
	print(_get_energy_from_offset(offset))

func _get_energy_from_offset(offset: float) -> float:
	var off = offset
	if off < day_start or off > day_end:
		#night
		return 0.0
	elif off < day_start + dawn_duration:
		# dawn
		return (off - day_start) / dawn_duration * MAX_ENERGY
	elif off > day_end - dusk_duration:
		# dusk
		return (day_end - off) / dusk_duration * MAX_ENERGY
	else:
		return MAX_ENERGY
	
func _get_offset_from_cur_time() -> float:
	var time = OS.get_time()
	var cur_time_ms = OS.get_system_time_msecs()
	
	var ms: float = time.hour * 60 * 60 * 1000.0
	ms += time.minute * 60 * 1000.0
	ms += time.second * 1000.0
	ms += cur_time_ms - floor(cur_time_ms / 1000.0) * 1000.0
	return ms / day
