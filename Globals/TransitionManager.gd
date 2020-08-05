extends ViewportContainer

var player: Spatial
var dest_door: Spatial

func _ready():
	var m = self.material as ShaderMaterial
	m.set_shader_param("animation_progress", 1.0)

func door_to(player: Spatial, dest_door: Spatial):
	self.player = player
	self.dest_door = dest_door
	fade_out()


func fade_out():
	$AnimationPlayer.play("fade_out")

func fade_in():
	$AnimationPlayer.play("fade_in")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out" and player != null and dest_door != null:
		teleport()

func teleport():
	# go to door
	var pos = dest_door.to_global(Vector3.ZERO)
	player.set_global_transform(Transform(player.get_global_transform().basis, pos))
	var e: GameEnvironment = get_node('/root/World/Environment')
	# when set to null it disables custom env
	e.override_env = dest_door.custom_env
	fade_in()
	player = null
	dest_door = null
