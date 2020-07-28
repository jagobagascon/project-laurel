tool
class_name BaseTown
extends Spatial

func _ready():
	pass # Replace with function body.



func _on_Environment_time_change(status):
	match status:
		GameEnvironment.Status.DAY:
			$StreetLights.off()
		GameEnvironment.Status.NIGHT, GameEnvironment.Status.DAWN, GameEnvironment.Status.DUSK:
			$StreetLights.on()
