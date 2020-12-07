class_name NPC
extends Spatial

onready var actions_mgr = $"/root/ActionsManager"

func _ready():
	pass

func _on_NPC_reachable(area):
	print("Hey")


func _on_NPC_unreachable(area):
	print("Bye")
