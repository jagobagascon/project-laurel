extends Spatial

func _ready():
	pass

func _process(_delta):
	$UI/Pos.text = "Pos = " + str($Player.translation.x) + ", " + str($Player.translation.y) + ", " + str($Player.translation.z)
