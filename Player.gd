extends KinematicBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const FORWARD = "player_forward"
const BACK = "player_back"
const LEFT = "player_left"
const RIGHT = "player_right"
const BRAKE = "player_brake"

const SPEED = 0.03

var projection_plane = Plane.PLANE_XY

func _ready():
	_update_sprite()

# 2D sprites are positioned at a 45 degree angle to directly face the camera
# that creates a problem when near 3D structures, as the top of the sprite can
# go into the structure.
# This function takes the $Placeholder (a plane facing the camera) and projects
# it into a vertical plane (0, 0, 1). 
# This way we fake the sprite facing the camera and avoid those problems.
func _update_sprite():
	# project mesh to Z = 0 to keep it vertical while looking at the camera
	var mesh_arr = []
	mesh_arr.resize(ArrayMesh.ARRAY_MAX)
	var vertices = PoolVector3Array()
	var UVs = PoolVector2Array()
	var normals = PoolVector3Array()

	var left = 0
	var top = 0
	var right = 0
	var bottom = 0
	var faces = $Placeholder.mesh.get_faces()
	# get bounds to calculate UVs
	for f in faces:
		left = min(left, f.x)
		top = max(top, f.z)
		right = max(right, f.x)
		bottom = min(bottom, f.z)

	var width = right - left
	var height = top - bottom
	for f in faces:
		vertices.push_back(_vertex_projected(Vector3(f.x, f.y,  f.z)))
		UVs.push_back(Vector2((f.x - left) / width, (f.z - bottom) / height))
		# to the camera, and up: front and up in local space.
		normals.push_back(Vector3(0, 1, 1))
	
	mesh_arr[ArrayMesh.ARRAY_TEX_UV] = UVs
	mesh_arr[ArrayMesh.ARRAY_VERTEX] = vertices
	mesh_arr[ArrayMesh.ARRAY_NORMAL] = normals
	
	$Skin.translation.y = -_min_y(vertices)
	$Skin.mesh = ArrayMesh.new()
	$Skin.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arr)
	var aabb = $Skin.mesh.get_aabb();
	($CollisionShape.shape as BoxShape).extents.x = aabb.size.x/2.0
	($CollisionShape.shape as BoxShape).extents.y = aabb.size.y/2.0
	($CollisionShape.shape as BoxShape).extents.x = aabb.size.x/2.0
	$CollisionShape.translation.y = aabb.size.y / 2
	
	$Placeholder.hide()

func _min_y(vertices):
	var m = vertices[0].y
	for v in vertices:
		m = min(m, v.y)
	return m

func _vertex_projected(v: Vector3) -> Vector3:
	v = $Placeholder.to_global(v)
	var screen_pos: Vector2 = $Camera.unproject_position(v)
	var normal: Vector3 = $Camera.project_ray_normal(screen_pos)
	var origin: Vector3 = $Camera.project_ray_origin(screen_pos)
	origin = to_local(origin)
	var intersection = projection_plane.intersects_ray(origin, normal)
	if intersection != null:
		v = intersection
	return v



func _physics_process(_delta):
	var direction: Vector3 = Vector3()

	if Input.is_action_pressed(FORWARD):
		direction.z = -1
		
	if Input.is_action_pressed(BACK):
		direction.z = 1
		
	if Input.is_action_pressed(LEFT):
		direction.x = -1
		
	if Input.is_action_pressed(RIGHT):
		direction.x = 1
	
	# test collision before moving to avoid flickering when pushing a wall
	# if one of the axis is blocked by a wall, move along the other axis:
	var directionX: Vector3 = Vector3(direction.x, 0, 0)
	var directionZ: Vector3 = Vector3(0, 0, direction.z)
	if not test_move(global_transform, direction.normalized() * SPEED):
		var _collision = move_and_collide(direction.normalized() * SPEED)
	elif not test_move(global_transform, directionX.normalized() * SPEED):
		var _collision = move_and_collide(directionX.normalized() * SPEED)
	elif not test_move(global_transform, directionZ.normalized() * SPEED):
		var _collision = move_and_collide(directionZ.normalized() * SPEED)
