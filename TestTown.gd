tool
class_name BaseTown
extends Spatial

func _ready():
	pass

func _on_Environment_time_change(status):
	match status:
		GameEnvironment.Status.DAY:
			$StreetLights.turn_off()
		GameEnvironment.Status.NIGHT, GameEnvironment.Status.DAWN, GameEnvironment.Status.DUSK:
			$StreetLights.turn_on()
