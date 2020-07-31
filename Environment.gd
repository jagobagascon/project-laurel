tool
class_name GameEnvironment
extends Spatial

signal time_change

export var force_time: bool = false
export(float, 0, 1) var forced_time: float = 0

const DAY_DURATION = 24 * 60 * 60 * 1000

const day_start: float = 7.0 / 24.0
const day_end: float = 19.0 / 24.0

const dawn_duration: float = 1 / 24.0
const dusk_duration: float = 1 / 24.0

const MAX_SUN_ENERGY = 1.0

const MIN_SKY_ENERGY: float = .2
const MAX_SKY_ENERGY: float = 2.0

const DAY_START_ROTATION = -90
const DAY_END_ROTATION = 90

const DAY_SKY_TOP_COLOR: Color = Color(0.21, 0.31, 0.55)
const DAY_SKY_HORIZON_COLOR: Color = Color(0.55, 0.7, 0.8)

const DAWN_SKY_COLOR: Color = Color(0.84, 0.53, 0.0)

# MODIFY WITH CARE
######################################
var offset = 0
enum Status { DAWN, DAY, DUSK, NIGHT }
var cur_status
######################################

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_offset_from_cur_time()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	_update_offset_from_cur_time()
	_update_sun_moon()

func _update_offset_from_cur_time() -> void:
	# allow time forcing for debugging purpouses
	if force_time:
		offset = forced_time
	else:
		var time = OS.get_time()
		var cur_time_ms = OS.get_system_time_msecs()
		
		var ms: float = time.hour * 60 * 60 * 1000.0
		ms += time.minute * 60 * 1000.0
		ms += time.second * 1000.0
		ms += cur_time_ms - floor(cur_time_ms / 1000.0) * 1000.0
		offset = ms / DAY_DURATION
	_notify_status_changed()

func _notify_status_changed():
	var new_status = _get_cur_status()
	if new_status != cur_status:
		emit_signal("time_change", new_status)
		cur_status = new_status

func _get_cur_status():
	if _is_dawn():
		return Status.DAWN
	elif _is_dusk():
		return Status.DUSK
	elif _is_day():
		return Status.DAY
	elif _is_night():
		return Status.NIGHT
	else:
		# unreachable
		return null

func _update_sun_moon() -> void:
	var rot = _get_sun_rotation_from_offset()
	$SunPos.rotation_degrees.z = rot
	$SunPos/Sun.light_energy = _get_sun_energy_from_offset()
	$SunPos/Sun.light_color = _get_sun_color_from_offset()
	$WorldEnvironment.environment.background_energy = _get_sky_energy_from_offset()

func _get_sun_rotation_from_offset() -> float:
	# sun is visible from -90 to 90 this range should be for daylight
	if _is_day():
		return _offset_to_rotation(offset, day_start, day_end, DAY_START_ROTATION, DAY_END_ROTATION)
	else: #night
		return _offset_to_rotation(offset, day_end, day_start, DAY_END_ROTATION, DAY_START_ROTATION)

func _offset_to_rotation(global_offset, from_off, to_off, from_rot, to_rot) -> float:
	var from = from_off
	var to = to_off
	if to < from:
		to += 1.0 # offset resets at 1
	if global_offset < from: # position offset inside (from, to)
		global_offset += 1.0
	
	var cycle_offset = (global_offset - from) / (to - from)
	
	if to_rot < from_rot:
		to_rot += 360 # rotation resets at 180
	
	var rot = from_rot + cycle_offset * (to_rot - from_rot)
	return rot

func _get_sun_energy_from_offset() -> float:
	if _is_night():
		#night
		return 0.0
	elif _is_dawn():
		return min(1.0, _offset_in_dawn() * 2.0) * MAX_SUN_ENERGY
	elif _is_dusk():
		return min(1.0, 1.0 - _offset_in_dusk()) * MAX_SUN_ENERGY
	else: # normal day
		return MAX_SUN_ENERGY

func _get_sun_color_from_offset() -> Color:
	if _is_dawn():
		return Color.orange.linear_interpolate(Color.white, _offset_in_dawn())
	elif _is_dusk():
		return Color.white.linear_interpolate(Color.orange, _offset_in_dusk())
	else:
		return Color.white


func _get_sky_energy_from_offset() -> float:
		# Add sky ambient light before sunrise
	if _is_predawn():
		return _interpolate(_offset_in_predawn(), MIN_SKY_ENERGY, MAX_SKY_ENERGY)
	elif _is_postdusk():
		return _interpolate(_offset_in_postdusk(), MAX_SKY_ENERGY, MIN_SKY_ENERGY)
	elif _is_night():
		return MIN_SKY_ENERGY
	else: # normal day
		return MAX_SKY_ENERGY

func _is_night() -> bool:
	return not _is_day()

func _is_day() -> bool:
	return _between(offset, day_start, day_end)

func _is_dawn() -> bool:
	return _between(offset, day_start, day_start + dawn_duration)
func _offset_in_dawn() -> float:
	return _offset_in_range(offset, day_start, day_start + dawn_duration)
func _is_predawn() -> bool:
	return _between(offset, day_start - dawn_duration, day_start)
func _offset_in_predawn() -> float:
	return _offset_in_range(offset, day_start - dawn_duration, day_start)

func _is_dusk() -> bool:
	return _between(offset, day_end - dusk_duration, day_end)
func _offset_in_dusk() -> float:
	return _offset_in_range(offset, day_end - dusk_duration, day_end)
func _is_postdusk() -> bool:
	return _between(offset, day_end, day_end + dusk_duration)
func _offset_in_postdusk() -> float:
	return _offset_in_range(offset, day_end, day_end + dusk_duration)


func _between(var val, var from, var to) -> bool:
	return val >= from and val <= to
func _offset_in_range(var off, var from, var to) -> float:
	return (off - from) / (to - from)
func _interpolate(var off, var low, var high) -> float:
	return low + (high - low) * off
