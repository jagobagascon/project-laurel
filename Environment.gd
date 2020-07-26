extends Spatial

const DAY_DURATION = 24 * 1000

const day_start: float = 6.0 / 24.0
const day_end: float = 19.0 / 24.0

const day_duration: float = day_end - day_start
const dawn_duration: float = 1 / 24.0
const dusk_duration: float = 1 / 24.0

const MAX_ENERGY = 1.0

const DAY_START_ROTATION = -90
const DAY_END_ROTATION = 90

const DAY_SKY_TOP_COLOR: Color = Color(0.21, 0.31, 0.55)
const DAY_SKY_HORIZON_COLOR: Color = Color(0.55, 0.7, 0.8)

const DAWN_SKY_COLOR: Color = Color(0.84, 0.53, 0.0)
var offset = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_offset_from_cur_time()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	_update_offset_from_cur_time()
	_set_sun()
	_set_env()

func _update_offset_from_cur_time() -> void:
	var time = OS.get_time()
	var cur_time_ms = OS.get_system_time_msecs()
	
	var ms: float = time.hour * 60 * 60 * 1000.0
	ms += time.minute * 60 * 1000.0
	ms += time.second * 1000.0
	ms += cur_time_ms - floor(cur_time_ms / 1000.0) * 1000.0
	offset = ms / DAY_DURATION

func _set_sun() -> void:
	$SunPos.rotation_degrees.z = _get_sun_rotation_from_offset()
	$SunPos/Sun.light_energy = _get_energy_from_offset()

func _get_sun_rotation_from_offset() -> float:
	# sun is visible from -90 to 90 this range should be for daylight
	if _is_day():
		var from = day_start #+ dawn_duration
		var to = day_end #- dusk_duration
		var day_offset = (offset - from) / (to - from)
		return DAY_START_ROTATION + day_offset * (DAY_END_ROTATION - DAY_START_ROTATION)
	else: #night
		return 0.0 # does not matter

func _get_energy_from_offset() -> float:
	if _is_night():
		#night
		return 0.0
	elif _is_dawn():
		# dawn
		var dawn_off = (offset - day_start) / dawn_duration
		return dawn_off * dawn_off * dawn_off * MAX_ENERGY
	elif _is_dusk():
		# dusk
		var dusk_off = (day_end - offset) / dusk_duration
		return dusk_off * dusk_off * dusk_off * MAX_ENERGY
	else: # normal day
		return MAX_ENERGY

func _set_env() -> void:
	var off = 0
	if _is_dawn():
		off = (offset - day_start) / dawn_duration
	elif _is_dusk():
		off = (day_end - offset) / dusk_duration
	else:
		$WorldEnvironment.environment.ambient_light_sky_contribution = 1
		return
	
	var dawn_amount = 0.3
	if off < 0.5:
		off *= 2
		$WorldEnvironment.environment.ambient_light_sky_contribution = 1.0 - off * dawn_amount
	else:
		off = (off - 0.5) * 2
		$WorldEnvironment.environment.ambient_light_sky_contribution = (1.0 - dawn_amount) + off * dawn_amount

func _is_night() -> bool:
	return not _is_day()

func _is_day() -> bool:
	return offset > day_start and offset < day_end
	
func _is_dawn() -> bool:
	return offset < day_start + dawn_duration and offset > day_start

func _is_dusk() -> bool:
	return offset > day_end - dusk_duration and offset < day_end
