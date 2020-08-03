extends KinematicBody

const SPEED =  2
const G = 25
var moving_direction = Vector3()


onready var actionsManager = $"/root/ActionsManager"

func _physics_process(delta):
	_character_movement(delta)

func _character_movement(delta):
	var direction = _get_direction_by_input()
	
	moving_direction.x = direction.x * SPEED
	moving_direction.y += direction.y - G * delta
	moving_direction.z = direction.z * SPEED
	
	moving_direction = move_and_slide(moving_direction, Vector3.UP)


func _get_direction_by_input() -> Vector3:
	var direction: Vector3 = Vector3()

	var animation = "still"
	if Input.is_action_pressed("player_left"):
		animation = "left"
		direction.x = -1
		
	if Input.is_action_pressed("player_right"):
		animation = "right"
		direction.x = 1
	
	if Input.is_action_pressed("player_forward"):
		animation = "back"
		direction.z = -1
		
	if Input.is_action_pressed("player_back"):
		animation = "front"
		direction.z = 1

	if direction.length() == 0:
		animation = "still"
	
	$Sprite.animation = animation
	
	return direction.normalized()


func _process(_delta):
	# show / hide character actions
	if actionsManager.action_ready():
		var action = actionsManager.current_action()
		_show_action(action)
		if Input.is_action_just_pressed("player_action"):
			print("Action: " + action.to_string())
	else:
		_hide_action()

func _show_action(action):
	$PlayerUI/Action.show()
	var label_pos = $Camera.unproject_position($HintsTarget.to_global(Vector3()))
	$PlayerUI/Action.set_position(label_pos)
	$PlayerUI/Action/Key.text = "E"
	$PlayerUI/Action/Text.text = action.to_string()
	
func _hide_action():
	$PlayerUI/Action.hide()


