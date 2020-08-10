extends KinematicBody
class_name Player

var _input_enabled: bool = true

const MAX_SPEED =  2
const TERMINAL_SPEED = 20
const ACCELERATION = .25
const G = .98
var _velocity = Vector3()
var _grounded = true

# for slopes
onready var actionsManager = $"/root/ActionsManager"
onready var animationTree = $AnimationTree
onready var animationState = $AnimationTree.get("parameters/playback")

func input_enabled(enabled: bool):
	_input_enabled = enabled
	if not enabled:
		_velocity = Vector3.ZERO

func _physics_process(_delta):
	if _input_enabled:
		_character_movement()
	else:
		# Stop character animation
		_update_animation(Vector3())

func _character_movement():
	var direction: Vector3 = _get_direction_by_input()
	_update_animation(direction)
	
	if direction.length() == 0:
		_velocity = _velocity.move_toward(Vector3.ZERO, ACCELERATION)
	else:
		_velocity = _velocity.move_toward(direction * MAX_SPEED, ACCELERATION)
	
	if not _grounded:
		_velocity.y -= G
	else:
		# if we dont apply some negative force is_on_floor_returns false
		# but if we apply full gravity while on floor, player movement gets
		# changed on slopes (sliding down the slop)
		_velocity.y = -0.0000001
	
	_velocity = move_and_slide_with_snap(_velocity, Vector3(0, -0.1, 0), Vector3.UP, true)
	if self.is_on_floor():
		_grounded = true
	else:
		_grounded = false

func _get_direction_by_input() -> Vector3:
	var direction: Vector3 = Vector3.ZERO
	
	direction.x = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	direction.z = Input.get_action_strength("player_back") - Input.get_action_strength("player_forward")
	return direction.normalized()

func _update_animation(direction: Vector3):
	if direction.length() == 0:
		animationState.travel("Still")
	else:
		var direction2d = Vector2(direction.x, -direction.z)
		animationState.travel("Walk")
		# only update blend position when we are moving.
		# It will be remembered when stopping
		animationTree.set("parameters/Still/blend_position", direction2d)
		animationTree.set("parameters/Walk/blend_position", direction2d)

func _process(_delta):
	# show / hide character actions
	if actionsManager.action_ready():
		var action = actionsManager.current_action()
		_show_action(action)
		if Input.is_action_just_pressed("player_action"):
			actionsManager.do_action(self, action)
	else:
		_hide_action()

func _show_action(action):
	$PlayerUI/Action.show()
	var label_pos = $Camera.unproject_position($HintsTarget.to_global(Vector3()))
	$PlayerUI/Action.set_position(label_pos)
	$PlayerUI/Action/Key.text = "<Space>"
	$PlayerUI/Action/Text.text = action.to_string()
	
func _hide_action():
	$PlayerUI/Action.hide()


