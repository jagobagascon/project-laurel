tool
extends MeshInstance

export var size: float = 5.0;
export var gravity_force: float = 1.0;
var _applied_size: float
var _applied_gravity_force: float

func _process(delta):
	if size != _applied_size:
		_apply_size()
	if gravity_force != _applied_gravity_force:
		_apply_gravity_force()

func _apply_size():
	var m = get_surface_material(0) as ShaderMaterial

	m.set_shader_param("Size", size)
	(mesh as SphereMesh).radius = size
	(mesh as SphereMesh).height = 2 * size
	_applied_size = size
	
func _apply_gravity_force():
	var m = get_surface_material(0) as ShaderMaterial
	m.set_shader_param("GravityForce", gravity_force)
	_applied_gravity_force = gravity_force
	
