extends Spatial
class_name InPath

export(String, FILE) var scene_path: String

func _ready():
	get_parent().register_in_path(self)
