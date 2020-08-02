extends KinematicBody

const SPEED = 2

var projection_plane = Plane.PLANE_XY

onready var actionsManager = $"/root/ActionsManager"

func _physics_process(delta):
	_character_movement(delta)

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

func _character_movement(delta):
	var wanted_direction: Vector3 = _get_direction_by_input()
	var _collision = move_and_collide(wanted_direction * SPEED * delta)

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

