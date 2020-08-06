extends Node

onready var transition_manager = $"/root/TransitionManager"
var Action = preload("res://Player/Action.gd")

var _cur_action: Action
var doors = {}

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

func do_action(player: Spatial, action: Action):
	match (action.type):
		Action.Type.ENTER_DOOR:
			var door: Door = action.data
			if doors.has(door.connection):
				var conected_doors = doors[door.connection]
				for dest_door in conected_doors:
					if dest_door.id != door.id:
						transition_manager.door_to(player, dest_door)

###########################
# DOOR ACTIONS

func register_door(door: Door):
	if not doors.has(door.connection):
		doors[door.connection] = [door]
	else:
		doors[door.connection].append(door)

func on_Door_reachable(door: Door):
	# This always overrides
	_cur_action = Action.new(Action.Type.ENTER_DOOR, door)

func on_Door_unreachable(door: Door):
	if !_cur_action:
		return
	
	match (_cur_action.type):
		Action.Type.ENTER_DOOR:
			if _cur_action.data == door:
				_cur_action = null
