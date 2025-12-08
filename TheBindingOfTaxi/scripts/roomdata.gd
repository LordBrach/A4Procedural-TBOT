@tool
class_name RoomData extends Node2D

@export_tool_button("Save Room")
var buttonSave = save_room
@export_tool_button("Load Room")
var buttonLoad = load_room

@export_group("Edit Exits Data")
@export_tool_button("Serialize Exits at Current Pos")
var buttonDirection = save_direction
@export_tool_button("Show Exits Saved")
var buttonShowDirection = show_direction

@export_category("General Infos")
@export var roomName : String = "new_room"
@export var directory : String = "TheBindingOfTaxi/ressources/roomdata/"
@export var isImportantBuilding : bool = false
var lastSaveName : String = ""
var lastSaveTry : bool = false

@export_group("TileMapLayers")
@export var RoadLayer : TileMapLayer
@export var WallLayer : TileMapLayer
@export var ClientNPropsLayer : TileMapLayer
@export var DecorationLayer : TileMapLayer

@export_group("")
@export var roomSize : Vector2i = Vector2i.ONE
@export_group("Exits Parameters")
@export var currentPos : Vector2i = Vector2i.ONE
#@export_flags("WEST", "NORTH", "SOUTH", "EAST") var DirectionTest : int = 0;
#@export var exits : Array[Exit]

## Les sorties activées de la salle
@export var ActiveExits: Dictionary[Globals.Directions, bool] = \
{Globals.Directions.WEST: false, Globals.Directions.EAST: false,\
Globals.Directions.NORTH: false, Globals.Directions.SOUTH: false};

@export var exits : Dictionary[Vector2i, int] = {}

func _ready() -> void:
	pass

func getExits(a_worldPos : Vector2i) -> int:
	return exits.get(a_worldPos - currentPos, 0)

#region Save-Load

func save_direction() -> void : #Editor Only
	
	var newPos = currentPos - Vector2i.ONE
	
	if (roomSize.x * roomSize.y <= 0) :
		print("Serialize Exits Failed : Invalid Room Size, must be at (1, 1) or above")
		return
	
	if (newPos.x >= roomSize.x || newPos.x < 0 || newPos.y >= roomSize.y || newPos.y < 0) :
		print("Serialize Exits Failed : Invalid Current Position, must be between (1, 1) (", roomSize.x,", ", roomSize.y, ") or above")
		return
	
	if (exits.size() < roomSize.x * roomSize.y || exits.size() > roomSize.x * roomSize.y) :
		exits.clear()
		
		for x in range(roomSize.x) :
			for y in range(roomSize.y) :
				exits.set(Vector2i(x, y), 0)

	
	
	var count : int = 0
	var value : int = 0
	for direction in ActiveExits :
		if (ActiveExits.get(direction) == true) :
			value += 1 << count
		count += 1
	
	exits[newPos] = value
	print("Serialized exits at (", currentPos.x, ", ", currentPos.y, ")")

func show_direction() -> void : #Editor Only
	var y : int = roomSize.y - 1
	var text : Array[String] = []
	
	if (roomSize.x * roomSize.y != exits.size()) :
		print("Show Exits Failed : Room Size indicated wasn't the same has the number of Exits, pls save again at the correct coordinate of exits")
		return
	
	while(y >= 0) :
		var top : String = ""
		var middle : String = ""
		var bottom : String = ""
		
		for x in range(roomSize.x) :
			var dir : int = exits[Vector2i(x, y)]
			
			if (dir & 1 << 2) :
				top += "X|X"
			else :
				top += "XXX"
			
			if (dir & 1 << 0 && dir & 1 << 1) :
				middle += "- -"
			elif (dir & 1 << 0) :
				middle += "- X"
			elif (dir & 1 << 1) :
				middle += "X -"
			else :
				middle += "X X"
			
			if (dir & 1 << 3) :
				bottom += "X|X"
			else :
				bottom += "XXX"
		
		text.append(top)
		text.append(middle)
		text.append(bottom)
		
		y -= 1
	
	print("Exits patterns :")
	for line in text :
		print(line)
	print("")

func save_room() -> void : #Editor Only
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
	var clientNProps_layer_data : TilemapResource
	var decoration_layer_data : TilemapResource
	
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
	if(ClientNPropsLayer == null):
		print("Save Room Failed : Missing ClientNPropsLayer TileMapLayer value")
		return
	else :
		clientNProps_layer_data = get_tilemap_data(ClientNPropsLayer)
	if(DecorationLayer == null):
		print("Save Room Failed : Missing DecorationLayer TileMapLayer value")
		return
	else :
		decoration_layer_data = get_tilemap_data(DecorationLayer)
	
	if (road_layer_data.size.x % Globals.roomSize.x != 0 || road_layer_data.size.y % Globals.roomSize.y != 0 || road_layer_data.size.x * road_layer_data.size.y <= 0) :
		print("Save Room Failed : Room size (", road_layer_data.size.x, ", ", road_layer_data.size.y, ") is not correct, make sure the RoadLayer size is a multiple of (", Globals.roomSize.x, ", ", Globals.roomSize.y, ")")
		return
	elif (road_layer_data.size.x / Globals.roomSize.x != roomSize.x || road_layer_data.size.y / Globals.roomSize.y != roomSize.y) :
		roomSize.x = road_layer_data.size.x / Globals.roomSize.x
		roomSize.y = road_layer_data.size.y / Globals.roomSize.y
		save_direction()
		print("Save Room Failed : indicated Rome size wasn't accurate, it was fix and Exits have been reset")
		show_direction()
		return
	
	room_data.room_name = roomName
	room_data.is_special_room = isImportantBuilding
	
	room_data.room_size = Vector2i(road_layer_data.size.x / Globals.roomSize.x, road_layer_data.size.y / Globals.roomSize.y)
	if (exits.size() != roomSize.x * roomSize.y) :
		print("Save Room Failed : Missing exits reference, check 'Show Direction Saved' and call the button 'Save Direction at Current Pos' if necessary")
		return
		
	room_data.exits = exits
	room_data.allExits = get_all_exits(exits)
	
	ResourceSaver.save(road_layer_data, dirPath + "/road_layer.tres")
	room_data.road_layer_path = dirPath + "/road_layer.tres"
	ResourceSaver.save(wall_layer_data, dirPath + "/wall_layer.tres")
	room_data.wall_layer_path = dirPath + "/wall_layer.tres"
	ResourceSaver.save(clientNProps_layer_data, dirPath + "/clientNProps_layer.tres")
	room_data.clientNProps_layer_path = dirPath + "/ClientNProps_layer.tres"
	ResourceSaver.save(decoration_layer_data, dirPath + "/decoration_layer.tres")
	room_data.decoration_layer_path = dirPath + "/decoration_layer.tres"
	
	ResourceSaver.save(room_data, dirPath + "/" + roomName + ".tres")
	
	print(roomName, ".tres Saved")

func get_all_exits(a_exits : Dictionary[Vector2i, int]) -> int :
	var result : int = 0
	
	for exit in a_exits :
		var value : int = a_exits[exit]
		
		if (!(result & 1 << 0) && exit.x == 0 && value & 1 << 0) :
			result += 1 << 0
		if (!(result & 1 << 1) && exit.x == roomSize.x - 1 && value & 1 << 1) :
			result += 1 << 1
		if (!(result & 1 << 3) && exit.y == 0 && value & 1 << 3) :
			result += 1 << 3
		if (!(result & 1 << 2) && exit.y == roomSize.y - 1 && value & 1 << 2) :
			result += 1 << 2
	
	return result

func get_tilemap_data(a_tilemap : TileMapLayer) -> TilemapResource :
	var data = TilemapResource.new()
	
	var used_rect = a_tilemap.get_used_rect()
	data.size = Vector2i(used_rect.size.x, used_rect.size.y)
	data.tilesbit = a_tilemap.tile_map_data
	
	return data

func load_room() -> void : #Editor Only
	
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
	name = roomName
	
	isImportantBuilding = a_roomData.is_special_room
	exits = a_roomData.exits
	
	set_tilemap_data(RoadLayer, load(a_roomData.road_layer_path))
	set_tilemap_data(WallLayer, load(a_roomData.wall_layer_path))
	set_tilemap_data(ClientNPropsLayer, load(a_roomData.clientNProps_layer_path))
	set_tilemap_data(DecorationLayer, load(a_roomData.decoration_layer_path))
	print(roomName, " file loaded")

func set_tilemap_data(a_tilemap : TileMapLayer, a_data : TilemapResource) -> void :
	if (a_data == null) :
		print("Load Room Error : Given TilemapRessource is null and cannot be read")
		return
	
	a_tilemap.clear()
	a_tilemap.tile_map_data = a_data.tilesbit

#endregion
