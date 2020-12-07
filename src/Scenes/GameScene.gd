extends Node
class_name GameScene

signal on_town_exit(scene)

var _in_paths = []

func _ready():
	pass

func register_in_path(path: InPath):
	_in_paths.append(path)

func get_in_location(scene_path: String) -> Spatial:
	print(scene_path)
	print(_in_paths)
	for p in _in_paths:
		var in_path: InPath = p as InPath
		print(in_path)
		print(in_path)
		if in_path.scene_path == scene_path:
			return in_path
	return null

func _on_town_exit(town):
	emit_signal("on_town_exit", town)

