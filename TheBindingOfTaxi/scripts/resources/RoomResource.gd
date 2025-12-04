class_name RoomResource extends Resource

@export var room_name : String
@export var is_special_room : bool

@export var room_size : Vector2i

@export var road_layer_path : String
@export var wall_layer_path : String
@export var empty_layer_path : String

@export var exits : Dictionary[Vector2i, int]
