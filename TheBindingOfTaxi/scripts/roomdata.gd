extends Node2D
@export var room_size : Vector2i = Vector2i.ONE
@export var currentPos : Vector2i = Vector2i(0, 0)
#@export_flags("WEST", "NORTH", "SOUTH", "EAST") var DirectionTest : int = 0;
#@export var exits : Array[Exit]

## Les sorties activées de la salle
@export var ActiveExits: Dictionary[Globals.Directions, bool] = \
{Globals.Directions.WEST: false, Globals.Directions.EAST: false,\
Globals.Directions.NORTH: false, Globals.Directions.SOUTH: false};

var exitValue : int = 0;

func _ready() -> void:
	pass
