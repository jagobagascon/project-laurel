extends Spatial

func _process(delta):
	$Pos.text = "Pos = " + str($Player.translation.x) + ", " + str($Player.translation.y) + ", " + str($Player.translation.z)
