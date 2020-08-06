extends KinematicBody

const SPEED =  2
const ACCELERATION = .25
const G = 25
var velocity = Vector3()
var grounded = true

# for slopes
onready var actionsManager = $"/root/ActionsManager"

func _physics_process(delta):
	_character_movement(delta)

func _character_movement(delta):
	var direction: Vector3 = _get_direction_by_input()
	_update_animation(direction)
	
	if direction.length() == 0:
		velocity = velocity.move_toward(Vector3.ZERO, ACCELERATION)
	else:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION)
	
	if not grounded:
		velocity.y -= G * delta
	else:
		# if we dont apply some negative force is_on_floor_returns false
		# but if we apply full gravity while on floor, player movement gets
		# changed on slopes (sliding down the slop)
		velocity.y = -0.0000001
	
	velocity = move_and_slide_with_snap(velocity, Vector3(0, -0.1, 0), Vector3.UP, true)
	if self.is_on_floor():
		grounded = true
	else:
		grounded = false

func _get_direction_by_input() -> Vector3:
	var direction: Vector3 = Vector3.ZERO
	
	direction.x = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	direction.z = Input.get_action_strength("player_back") - Input.get_action_strength("player_forward")
	return direction.normalized()

func _update_animation(direction: Vector3):
	var animation = "still"
	if direction.x < 0:
		animation = "left"
	elif direction.x > 0:
		animation = "right"
	
	if direction.z < 0:
		animation = "back"
	elif direction.z > 0:
		animation = "front"

	if direction.length() == 0:
		animation = "still"
	
	$Sprite.animation = animation

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


