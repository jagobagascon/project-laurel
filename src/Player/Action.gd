class_name Action

var type
var data

enum Type {
	NONE, ENTER_DOOR
}

func _init(t, d = null):
	self.type = t
	self.data = d

func to_string() -> String:
	match self.type:
		Type.NONE:
			return "none"
		Type.ENTER_DOOR:
			return "enter door -> " + str(data)
	
	return "null"
