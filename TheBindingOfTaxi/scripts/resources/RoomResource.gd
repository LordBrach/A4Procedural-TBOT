class_name RoomResource extends Resource

@export var room_name : String = ""
@export var is_special_room : bool = false

@export var room_size : Vector2i = Vector2i.ONE

@export var road_layer_path : String = ""
@export var wall_layer_path : String = ""
@export var clientNProps_layer_path : String = ""
@export var decoration_layer_path : String = ""

@export var exits : Dictionary[Vector2i, int] = {}
@export var allExits : int = 0

func NumbOfExits() -> int :
	var result : int = 0
	
	if (allExits & 1 << 0) :
		result += 1
	if (allExits & 1 << 1) :
		result += 1
	if (allExits & 1 << 2) :
		result += 1
	if (allExits & 1 << 3) :
		result += 1
	
	return result
