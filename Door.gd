class_name Door
extends Area

export var id: int = 0
export var connection: int = 0
export var custom_env: Environment = null

onready var actions_mgr = $"/root/ActionsManager"

# Called when the node enters the scene tree for the first time.
func _ready():
	actions_mgr.register_door(self)
	connect("body_entered", self, "_on_Door_reachable")
	connect("body_exited", self, "_on_Door_unreachable")

func _on_Door_reachable(_body):
	actions_mgr.on_Door_reachable(self)
func _on_Door_unreachable(_body):
	actions_mgr.on_Door_unreachable(self)
