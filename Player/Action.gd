class_name Action

var type
var data

enum Type {
	NONE, ENTER_DOOR
}

func _init(type, data = null):
	self.type = type
	self.data = data

func to_string() -> String:
	match self.type:
		Type.NONE:
			return "none"
		Type.ENTER_DOOR:
			return "enter door -> " + str(data)
	
	return "null"
