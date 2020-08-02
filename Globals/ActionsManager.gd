extends Node

var Action = preload("res://Player/Action.gd")

var _cur_action: Action

var NONE_ACTION = Action.new(Action.Type.NONE)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func current_action():
	if _cur_action:
		return _cur_action
	else:
		return NONE_ACTION
		
func action_ready():
	return _cur_action != null

###########################
# DOOR ACTIONS

func on_Door_reachable(door_id: int):
	# This always overrides
	_cur_action = Action.new(Action.Type.ENTER_DOOR, door_id)

func on_Door_unreachable(door_id: int):
	if !_cur_action:
		return
	
	match (_cur_action.type):
		Action.Type.ENTER_DOOR:
			if _cur_action.data == door_id:
				_cur_action = null
