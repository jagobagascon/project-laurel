extends Spatial

onready var actions_mgr = $"/root/ActionsManager"

func _ready():
	pass

func _process(_delta):
	$UI/Pos.text = "Pos = " + str($Player.translation.x) + ", " + str($Player.translation.y) + ", " + str($Player.translation.z)
	$UI/Speed.text = "Action: " + actions_mgr.current_action().to_string()
