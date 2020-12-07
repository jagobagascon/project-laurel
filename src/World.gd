tool
extends Spatial

onready var _current_scene = $TestTown
onready var _transition_manager = $"/root/TransitionManager"

var _next_scene: String

func _on_Environment_time_change(status):
	match status:
		GameEnvironment.Status.DAY:
			$TestTown/StreetLights.turn_off()
		GameEnvironment.Status.NIGHT, GameEnvironment.Status.DAWN, GameEnvironment.Status.DUSK:
			$TestTown/StreetLights.turn_on()

func _process(_delta):
	$UI/Pos.text = "Pos = " + str($Player.translation.x) + ", " + str($Player.translation.y) + ", " + str($Player.translation.z)

func _on_town_exit(scene_id: String):
	self._next_scene = scene_id
	$Player.input_enabled(false)
	_transition_manager.fade_out(self, "_do_town_exit")

func _do_town_exit():
	# Remove the current level
	var scene_to_unload = $CurrentTown.get_child(0)
	var from_scene = (scene_to_unload as GameScene).filename
	$CurrentTown.remove_child(scene_to_unload)
	scene_to_unload.call_deferred("free")
	
	# Add the next level
	var scene_to_load = load(self._next_scene)
	var scene: GameScene = scene_to_load.instance()
	$CurrentTown.add_child(scene)
	
	# Set player position
	var player_pos_node = scene.get_in_location(from_scene)
	var pos = player_pos_node.to_global(Vector3.ZERO)
	$Player.set_global_transform(Transform($Player.get_global_transform().basis, pos))
	
	# listen signals
	scene.connect("on_town_exit", self, "_on_town_exit")
	
	_transition_manager.fade_in(self, '_done_town_exit')

func _done_town_exit():
	$Player.input_enabled(true)
	self._next_scene = ""
