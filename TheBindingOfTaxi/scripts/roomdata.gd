@tool
class_name RoomData extends Node2D

@export_tool_button("Save Room")
var buttonSave = save_room
@export_tool_button("Load Room")
var buttonLoad = load_room

@export var roomName : String = "new_room"
@export var directory : String = "TheBindingOfTaxi/ressources/roomdata/"
@export var isImportantBuilding : bool = false
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

var exitValue = 0

func _ready() -> void:
	pass


#region Save-Load

func save_room() -> void :
	if (roomName == null || roomName.is_empty()) :
		print("Save Room Failed : Room Name is empty")
	
	if (directory != null && !directory.is_empty() && !directory.ends_with("/")) :
		directory += "/"
	
	var dirPath = "res://" + directory
	
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
			print("Save Room ! WARNING ! : '" + roomName + "' already exist in this directory. If you want to overwrite this directory, press 'Save Room' button again")
			lastSaveName = roomName
			lastSaveTry = true
			return
	else :
		dir = DirAccess.make_dir_recursive_absolute(dirPath)
	
	lastSaveName = ""
	lastSaveTry = false
	
	print("Saving ", roomName, " file...")
	
	var room_data = RoomResource.new()
	var road_layer_data : TilemapResource
	var wall_layer_data : TilemapResource
	var empty_layer_data : TilemapResource
	
	if(RoadLayer == null):
		print("Save Room Failed : Missing RoadLayer TileMapLayer value")
		return
	else :
		road_layer_data = get_tilemap_data(RoadLayer)
	if(WallLayer == null):
		print("Save Room Failed : Missing WallLayer TileMapLayer value")
		return
	else :
		wall_layer_data = get_tilemap_data(WallLayer)
	if(EmptyLayer == null):
		print("Save Room Failed : Missing EmptyLayer TileMapLayer value")
		return
	else :
		empty_layer_data = get_tilemap_data(EmptyLayer)
	
	if (road_layer_data.size.x % Globals.roomSize.x != 0 || road_layer_data.size.y % Globals.roomSize.y != 0 || road_layer_data.size.x * road_layer_data.size.y <= 0) :
		print("Save Room Failed : Room size (", road_layer_data.size.x, ", ", road_layer_data.size.y, ") is not correct, make sure the RoadLayer size is a multiple of (", Globals.roomSize.x, ", ", Globals.roomSize.y, ")")
		return
	
	room_data.room_name = roomName
	room_data.is_special_room = isImportantBuilding
	
	room_data.room_size = Vector2i(road_layer_data.size.x / Globals.roomSize.x, road_layer_data.size.y / Globals.roomSize.y)
	
	ResourceSaver.save(road_layer_data, dirPath + "/road_layer.tres")
	room_data.road_layer_path = dirPath + "/road_layer.tres"
	ResourceSaver.save(wall_layer_data, dirPath + "/wall_layer.tres")
	room_data.wall_layer_path = dirPath + "/wall_layer.tres"
	ResourceSaver.save(empty_layer_data, dirPath + "/empty_layer.tres")
	room_data.empty_layer_path = dirPath + "/empty_layer.tres"
	
	ResourceSaver.save(room_data, dirPath + "/" + roomName + ".tres")
	
	print(roomName, ".tres Saved")

func get_tilemap_data(a_tilemap : TileMapLayer) -> TilemapResource :
	var data = TilemapResource.new()
	
	var used_rect = a_tilemap.get_used_rect()
	data.size = Vector2i(used_rect.size.x, used_rect.size.y)
	data.tilesbit = a_tilemap.tile_map_data
	
	data.tiles = []
	for y in range(used_rect.size.y):
		for x in range(used_rect.size.x):
			var cell = a_tilemap.get_cell_tile_data(Vector2i(x + used_rect.position.x, y + used_rect.position.y))
			data.tiles.append(cell)
	
	return data

func load_room() -> void :
	
	if (directory != null && !directory.is_empty() && !directory.ends_with("/")) :
		directory += "/"
	
	var dirPath = "res://" + directory + roomName
	if (DirAccess.open(dirPath) == null) :
		print("Load Room Failed : no directory")
	
	print("loading ", roomName, " file...")
	var room_data : RoomResource = load(dirPath + "/" + roomName + ".tres")
	load_room_data(room_data)

func load_room_data(a_roomData : RoomResource) -> void :
	roomName = a_roomData.room_name
	isImportantBuilding = a_roomData.is_special_room
	
	set_tilemap_data(RoadLayer, load(a_roomData.road_layer_path))
	set_tilemap_data(WallLayer, load(a_roomData.wall_layer_path))
	set_tilemap_data(EmptyLayer, load(a_roomData.empty_layer_path))
	print(roomName, " file loaded")

func set_tilemap_data(a_tilemap : TileMapLayer, a_data : TilemapResource) -> void :
	a_tilemap.clear()
	a_tilemap.tile_map_data = a_data.tilesbit

#endregion
