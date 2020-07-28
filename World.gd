tool
extends Spatial

func _process(delta):
	$UI/Pos.text = "Pos = " + str($Player.translation.x) + ", " + str($Player.translation.y) + ", " + str($Player.translation.z)

