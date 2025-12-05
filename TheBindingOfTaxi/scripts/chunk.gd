class_name Chunk extends Node2D

@export var chunkPosition : Vector2i = Vector2i.ZERO
@export var chunkBiome : WorldGen.Biomes = WorldGen.Biomes.None

var chunkExits : Dictionary[Vector2i, int] = {}
var roomTiles : Dictionary[Vector2i, RoomData] = {}


func SetExits() -> void :
	if (WorldGen != null) :
		chunkExits = WorldGen.GetAllConnections(chunkPosition)
	
	if (chunkExits.find_key(1 << 0) == null) :
		var rand : int = randi_range(Globals.chunkExitsRange.x, Globals.chunkExitsRange.y)
		for x in range(rand) :
			var pos : int = randi_range(0, Globals.chunkSize.y - 1)
			chunkExits.get_or_add(Vector2i(-1, pos), 1 << 0)
	if (chunkExits.find_key(1 << 1) == null) :
		var rand : int = randi_range(Globals.chunkExitsRange.x, Globals.chunkExitsRange.y)
		for x in range(rand) :
			var pos : int = randi_range(0, Globals.chunkSize.y - 1)
			chunkExits.get_or_add(Vector2i(Globals.chunkSize.x, pos), 1 << 1)
	if (chunkExits.find_key(1 << 2) == null) :
		var rand : int = randi_range(Globals.chunkExitsRange.x, Globals.chunkExitsRange.y)
		for x in range(rand) :
			var pos : int = randi_range(0, Globals.chunkSize.x - 1)
			chunkExits.get_or_add(Vector2i(pos, Globals.chunkSize.y), 1 << 2)
	if (chunkExits.find_key(1 << 3) == null) :
		var rand : int = randi_range(Globals.chunkExitsRange.x, Globals.chunkExitsRange.y)
		for x in range(rand) :
			var pos : int = randi_range(0, Globals.chunkSize.x - 1)
			chunkExits.get_or_add(Vector2i(pos, -1), 1 << 3)

func GetExits(a_direction : Globals.Directions = Globals.Directions.NONE) -> Dictionary[Vector2i, int] :
	var dirNum = a_direction as int
	
	if (dirNum == 0) :
		return chunkExits
	
	var list : Dictionary[Vector2i, int] = {}
	if (dirNum & 1 << 0) :
		for exit in chunkExits :
			if (chunkExits[exit] & 1 << 0) :
				list.set(exit, chunkExits[exit])
	elif (dirNum & 1 << 1) :
		for exit in chunkExits :
			if (chunkExits[exit] & 1 << 1) :
				list.set(exit, chunkExits[exit])
	elif (dirNum & 1 << 2) :
		for exit in chunkExits :
			if (chunkExits[exit] & 1 << 2) :
				list.set(exit, chunkExits[exit])
	elif (dirNum & 1 << 3) :
		for exit in chunkExits :
			if (chunkExits[exit] & 1 << 3) :
				list.set(exit, chunkExits[exit])
	
	return list

func _GetPositionFromRoomTile(a_roomTilePos : Vector2i) -> Vector2:
	var localPos = Vector2(a_roomTilePos.x * Globals.tileSize.x, a_roomTilePos.y * Globals.tileSize.y)
	var result : Vector2 = localPos + position
	return result

func _IsPosInside(a_pos : Vector2) -> bool:
	var result : bool = true
	
	if (!(position.x < a_pos.x && a_pos.x < position.x + Globals._GetPixelChunkSize().x)) :
		result = false
	elif (!(position.y < a_pos.y && a_pos.y < position.y + Globals._GetPixelChunkSize().y)) :
		result = false
	
	return result

func _IsTileInside(a_pos : Vector2i) -> bool :
	var result : bool = true
	
	if (!(0 < a_pos.x && a_pos.x < Globals.chunkSize.x)) :
		result = false
	elif (!(0 < a_pos.y && a_pos.y < Globals.chunkSize.x)) :
		result = false
	
	return result

func StartGeneration(a_pos : Vector2i, a_biome : WorldGen.Biomes) -> void :
	chunkPosition = a_pos
	position =Vector2(chunkPosition.x * Globals._GetPixelChunkSize().x, chunkPosition.y * Globals._GetPixelChunkSize().y)\
	 - Vector2(Globals._GetPixelChunkSize().x / 2, - Globals._GetPixelChunkSize().y / 2)
	
	chunkBiome = a_biome
	
	var roomlist : Array[RoomResource] = WorldGen.GetRooms(a_biome)
	if (roomlist.is_empty()) :
		print("list is null : ", a_biome)
		return
	
	if (WorldGen != null) :
		Generation(roomlist)
	else :
		print("Chunk Generation error : Bowser fart gif instance not found")

func Generation(a_roomList : Array[RoomResource]) -> void :
	
	var room : RoomResource = a_roomList.pick_random()
	if (room == null) :
		print("room is null")
		return
	
	var position : Vector2i = Vector2i(Globals.chunkSize.x / 2, Globals.chunkSize.y / 2) - Vector2i(room.room_size.x / 2, room.room_size.y / 2)
	
	TryPlaceRoom(position, room)
	
	return

func IsOccupied(a_roomTilePos : Vector2i, a_roomSize : Vector2i = Vector2i(1, 1)) -> bool :
	for i in range(0, a_roomSize.x):
		for j in range(0, a_roomSize.y):
			var target = Vector2i(a_roomTilePos.x + i, a_roomTilePos.y + j)
			if (!_IsTileInside(target) || roomTiles.has(target)):
				return false
	
	return true

func IsPositionable(a_roomTilePos : Vector2i, a_room : RoomResource) -> bool :
	for x in range(a_room.room_size.x) :
		var current = Vector2i(a_roomTilePos.x + x, a_roomTilePos.y)
		var target = current - Vector2i(0, 1)
		var tile = roomTiles.get(target)
		if (tile != null) :
			var tileExits = tile.getExits(target)
			if(!(tileExits & 1 << 2 && a_room.exits[current] & 1 << 3) && 
			(tileExits & 1 << 2 || a_room.exits[current] & 1 << 3)) :
				return false
		elif (chunkExits.get(target) != null && !(a_room.exits[current] & 1 << 3)) :
			return false
		
		target = current + Vector2i(0, a_room.room_size.y)
		tile = roomTiles.get(target)
		if (tile != null) :
			var tileExits = tile.getExits(target)
			if(!(tileExits & 1 << 3 && a_room.exits[current] & 1 << 2) && 
			(tileExits & 1 << 3 || a_room.exits[current] & 1 << 2)) :
				return false
		elif (chunkExits.get(target) != null && !(a_room.exits[current] & 1 << 2)) :
			return false
	
	for y in range(a_room.room_size.y) :
		var current = Vector2i(a_roomTilePos.x, a_roomTilePos.y + y)
		var target = current - Vector2i(1, 0)
		var tile = roomTiles.get(target)
		if (tile != null) :
			var tileExits = tile.getExits(target)
			if(!(tileExits & 1 << 1 && a_room.exits[current] & 1 << 0) && 
			(tileExits & 1 << 1 || a_room.exits[current] & 1 << 0)) :
				return false
		elif (chunkExits.get(target) != null && !(a_room.exits[current] & 1 << 0)) :
			return false
		
		target = current + Vector2i(a_room.room_size.x, 0)
		tile = roomTiles.get(target)
		if (tile != null) :
			var tileExits = tile.getExits(target)
			if(!(tileExits & 1 << 0 && a_room.exits[current] & 1 << 1) && 
			(tileExits & 1 << 0 || a_room.exits[current] & 1 << 1)) :
				return false
		elif (chunkExits.get(target) != null && !(a_room.exits[current] & 1 << 1)) :
			return false
	
	return true

func _IsAccessible(a_roomTilePos : Vector2i, a_direction : int) -> bool :
	
	return false

func TryPlaceRoom(a_roomTilePos : Vector2i, a_room : RoomResource) -> bool :
	
	if (!IsOccupied(a_roomTilePos, a_room.room_size) || !IsPositionable(a_roomTilePos, a_room)):
		print("Room Gen Stop : Room does not fit")
		return false
	print("Room Gen Info : Room does fit, creating instance...")
	
	var room = preload(Globals.RoomScnPath)
	var instance : RoomData = room.instantiate()
	self.add_child(instance)
	
	instance.currentPos = a_roomTilePos
	instance.position = Vector2(position.x + (a_roomTilePos.x * Globals._GetPixelRoomSize().x), position.y + -(a_roomTilePos.y * Globals._GetPixelRoomSize().y))
	instance.load_room_data(a_room)
	
	print("Room Gen Info : Room Instance '", instance.name, "' created at (", instance.position.x, ", ", instance.position.y, ")")
	
	for i in range(0, a_room.room_size.x):
		for j in range(0, a_room.room_size.y):
			var pos = Vector2i(a_roomTilePos.x + i, a_roomTilePos.y + j)
			roomTiles.assign({pos : a_room})
	
	return true
