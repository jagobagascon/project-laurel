extends Area
class_name OutPath

signal on_town_exit(scene_id)

export(String, FILE) var scene_path: String

func _ready():
	self.connect("body_entered", self, "_on_town_exit")

func _on_town_exit(_body):
	emit_signal("on_town_exit", scene_path)
