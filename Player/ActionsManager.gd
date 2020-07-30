extends Node

var Action = preload("res://Player/Action.gd")

var cur_action: Action

var NONE_ACTION = Action.new(Action.Type.NONE)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func current_action():
	if cur_action:
		return cur_action
	else:
		return NONE_ACTION

###########################
# DOOR ACTIONS

func on_Door_reachable(door_id: int):
	# This always overrides
	cur_action = Action.new(Action.Type.ENTER_DOOR, door_id)

func on_Door_unreachable(door_id: int):
	if !cur_action:
		return
	
	match (cur_action.type):
		Action.Type.ENTER_DOOR:
			if cur_action.data == door_id:
				cur_action = null
