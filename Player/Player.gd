extends KinematicBody

const SPEED = 3

var projection_plane = Plane.PLANE_XY

onready var actionsManager = $"/root/ActionsManager"

var facing: Vector2 = Vector2(0, -1)
var angle_0: Vector2 = Vector2(0, -1)

func _ready():
	_update_sprite()

func _physics_process(delta):
	_character_movement(delta)

func _process(_delta):
	# set character model rotation
	$main_character.rotation.y = facing.angle_to(angle_0)
	
	# show / hide character actions
	if actionsManager.action_ready():
		var action = actionsManager.current_action()
		_show_action(action)
		if Input.is_action_just_pressed("player_action"):
			print("Action: " + action.to_string())
	else:
		_hide_action()

func _show_action(action):
	$PlayerUI/Action.show()
	var label_pos = $Camera.unproject_position($HintsTarget.to_global(Vector3()))
	$PlayerUI/Action.set_position(label_pos)
	$PlayerUI/Action/Key.text = "E"
	$PlayerUI/Action/Text.text = action.to_string()
	
func _hide_action():
	$PlayerUI/Action.hide()

func _character_movement(delta):
	var wanted_direction: Vector2 = _get_direction_by_input()
	if wanted_direction.length() > 0:
		# smooth rotate character
		# lerp from current facing direction to wanted movement direction
		var angle = lerp_angle(angle_0.angle_to(facing), angle_0.angle_to(wanted_direction), .3)
		var movement_direction = angle_0.rotated(angle)
		
		# interpolate speed using the difference between the facing angle and the moving angle
		# the bigger the angle the slower the user will move.
		var speed_decrease_by_angle = (PI - abs(facing.angle_to(wanted_direction))) / PI
		var sp = SPEED * delta * speed_decrease_by_angle
		
		var move_dir = Vector3(movement_direction.normalized().x, 0, movement_direction.normalized().y)
		var want_dir = Vector3(wanted_direction.normalized().x, 0, wanted_direction.normalized().y)
		# want_dir == rotate smooth and move in player input direction
		# move_dir == rotate smooth and move in character direction
		var _collision = move_and_collide(want_dir * sp)
		facing = movement_direction
	

func _get_direction_by_input() -> Vector2:
	var direction: Vector2 = Vector2()

	if Input.is_action_pressed("player_forward"):
		direction.y = -1
		
	if Input.is_action_pressed("player_back"):
		direction.y = 1
		
	if Input.is_action_pressed("player_left"):
		direction.x = -1
		
	if Input.is_action_pressed("player_right"):
		direction.x = 1

	return direction.normalized()





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

