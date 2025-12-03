@tool
class_name RoomData extends Node2D

@export_tool_button("Save Room")
var button = save_room

@export var roomName : String = "new_room"
@export var dirPath : String = "TheBindingOfTaxi/ressources/roomdata/"
var lastSaveName : String = ""
var lastSaveTry : bool = false

@export var RoadLayer : TileMapLayer
@export var WallLayer : TileMapLayer
@export var EmptyLayer : TileMapLayer

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


func save_room() -> void :
	var dirPath = "res://" + dirPath
	
	var dir = DirAccess.open(dirPath)
	if (dir == null) :
		DirAccess.make_dir_recursive_absolute(dirPath)
	
	dirPath = dirPath + roomName
	dir = DirAccess.open(dirPath)
	if (dir != null) :
		if (roomName == lastSaveName && lastSaveTry) :
			DirAccess.remove_absolute(dirPath)
			dir = DirAccess.make_dir_recursive_absolute(dirPath)
		else :
			print("! WARNING ! : '" + roomName + "' already exist in this directory. If you want to overwrite this directory, press 'Save Room' button again")
			lastSaveName = roomName
			lastSaveTry = true
			return
	else :
		dir = DirAccess.make_dir_recursive_absolute(dirPath)
	
	lastSaveName = ""
	lastSaveTry = false
	
	print("Save Room Test : ", roomName)
	return
