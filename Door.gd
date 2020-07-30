class_name Door
extends Area

export var id: int = 0

onready var actions_mgr = $"/root/ActionsManager"

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_Door_reachable")
	connect("body_exited", self, "_on_Door_unreachable")

func _on_Door_reachable(_body):
	actions_mgr.on_Door_reachable(id)
func _on_Door_unreachable(_body):
	actions_mgr.on_Door_unreachable(id)
