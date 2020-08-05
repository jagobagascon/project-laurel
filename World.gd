tool
extends Spatial

onready var environment = $Environment

func _ready():
	pass

func _on_Environment_time_change(status):
	match status:
		GameEnvironment.Status.DAY:
			$TestTown/StreetLights.turn_off()
		GameEnvironment.Status.NIGHT, GameEnvironment.Status.DAWN, GameEnvironment.Status.DUSK:
			$TestTown/StreetLights.turn_on()

func _process(_delta):
	$UI/Pos.text = "Pos = " + str($Player.translation.x) + ", " + str($Player.translation.y) + ", " + str($Player.translation.z)
