extends ViewportContainer

var player: Player
var dest_door: Spatial

var on_fade_out_target: Object
var on_fade_out_method: String
var on_fade_in_target: Object
var on_fade_in_method: String

func _ready():
	var m = self.material as ShaderMaterial
	m.set_shader_param("animation_progress", 1.0)

func door_to(p: Player, door: Spatial):
	self.player = p
	self.player.input_enabled(false)
	self.dest_door = door
	fade_out(self, 'teleport')

func fade_out(obj: Object = null, method: String = ''):
	on_fade_out_target = obj
	on_fade_out_method = method
	$AnimationPlayer.play("fade_out")

func fade_in(obj: Object = null, method: String = ''):
	on_fade_in_target = obj
	on_fade_in_method = method
	$AnimationPlayer.play("fade_in")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out" and on_fade_out_target != null and on_fade_out_method != null:
		on_fade_out_target.call(on_fade_out_method)
		on_fade_out_target = null
	if anim_name == "fade_in" and on_fade_in_target != null and on_fade_in_method != null:
		on_fade_in_target.call(on_fade_in_method)
		on_fade_in_target = null
	

func teleport():
	if player == null or dest_door == null:
		return
	# go to door
	var pos = self.dest_door.to_global(Vector3.ZERO)
	self.player.set_global_transform(Transform(player.get_global_transform().basis, pos))
	var e: GameEnvironment = get_node('/root/World/Environment')
	# when set to null it disables custom env
	e.override_env = dest_door.custom_env
	fade_in()
	self.player.input_enabled(true)
	self.player = null
	self.dest_door = null
