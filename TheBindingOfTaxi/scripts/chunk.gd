class_name Chunk extends Node2D

@export var chunkPosition : Vector2i = Vector2i.ZERO
@export var chunkBiome : WorldGen.Biomes = WorldGen.Biomes.None

@export var chunkExits : Dictionary[Vector2i, int] = {}
@export var chunkExitsLinked : Dictionary[Vector2i, Vector2i] = {} #Accesible Pos : Exit Pos

@export var roomTiles : Dictionary[Vector2i, RoomData] = {}
@export var specialTileData : RoomData = null

@export var roadsAvailables : Dictionary[Vector2i, int] = {}

func SetExits() -> void :
	if (WorldGen != null) :
		chunkExits = WorldGen.GetAllConnections(chunkPosition)
	
	if (chunkExits.find_key(1 << 0) == null) :
		var rand : int = randi_range(Globals.chunkExitsRange.x, Globals.chunkExitsRange.y)
		for x in range(rand) :
			var pos : int = randi_range(1, Globals.chunkSize.y - 2)
			chunkExits.get_or_add(Vector2i(Globals.chunkSize.x, pos), 1 << 0)
	if (chunkExits.find_key(1 << 1) == null) :
		var rand : int = randi_range(Globals.chunkExitsRange.x, Globals.chunkExitsRange.y)
		for x in range(rand) :
			var pos : int = randi_range(1, Globals.chunkSize.y - 2)
			chunkExits.get_or_add(Vector2i(-1, pos), 1 << 1)
	if (chunkExits.find_key(1 << 2) == null) :
		var rand : int = randi_range(Globals.chunkExitsRange.x, Globals.chunkExitsRange.y)
		for x in range(rand) :
			var pos : int = randi_range(1, Globals.chunkSize.x - 2)
			chunkExits.get_or_add(Vector2i(pos, -1), 1 << 2)
	if (chunkExits.find_key(1 << 3) == null) :
		var rand : int = randi_range(Globals.chunkExitsRange.x, Globals.chunkExitsRange.y)
		for x in range(rand) :
			var pos : int = randi_range(1, Globals.chunkSize.x - 2)
			chunkExits.get_or_add(Vector2i(pos, Globals.chunkSize.y), 1 << 3)
	
	for exit in chunkExits :
		chunkExitsLinked.set(GetPosFacingExit(exit, chunkExits[exit]), exit)

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

func _GetTilePosFromGlobalPos(a_pos : Vector2) -> Vector2i :
	return Vector2i(a_pos.x - global_position.x, a_pos.y - global_position.x)

func _IsPosInside(a_pos : Vector2) -> bool:
	var result : bool = true
	
	if (!(position.x < a_pos.x && a_pos.x < position.x + Globals.GetPixelChunkSize().x)) :
		result = false
	elif (!(position.y < a_pos.y && a_pos.y < position.y + Globals.GetPixelChunkSize().y)) :
		result = false
	
	return result

func _IsTileInside(a_pos : Vector2i) -> bool :
	var result : bool = true
	
	if (!(a_pos.x >= 0 && a_pos.x < Globals.chunkSize.x)) :
		result = false
	elif (!(a_pos.y >= 0 && a_pos.y < Globals.chunkSize.x)) :
		result = false
	
	return result

func StartGeneration(a_pos : Vector2i, a_biome : WorldGen.Biomes, a_room : RoomResource = null) -> bool :
	chunkPosition = a_pos
	global_position = Vector2(chunkPosition.x * Globals.GetPixelChunkSize().x, chunkPosition.y * Globals.GetPixelChunkSize().y)\
	 - Vector2(Globals.GetPixelChunkSize().x / 2, - Globals.GetPixelChunkSize().y / 2)
	
	name = "Chunk_" + str(chunkPosition)
	chunkBiome = a_biome
	
	var roomlist : Array[RoomResource] = WorldGen.GetRooms(a_biome)
	if (roomlist.is_empty()) :
		printerr("Chunk Generation error : list is null for '", a_biome, "'")
		return false
	
	if (WorldGen != null) :
		SetExits()
		return Generation(roomlist, a_room)
	else :
		printerr("Chunk Generation error : WorldGenManager instance not found")
		return false

func Generation(a_roomList : Array[RoomResource], a_room : RoomResource = null) -> bool :
	
	var placed : bool = false
	
	#region FirstRoom
	var specials = WorldGen.GetSpecialsBiome(chunkBiome)
	specials.shuffle()
	
	if (a_room != null) :
		var position : Vector2i = Vector2i(Globals.chunkSize.x / 2, Globals.chunkSize.y / 2) - Vector2i(a_room.room_size.x / 2, a_room.room_size.y / 2)
		if (TryPlaceRoom(position, a_room)) :
			placed = true
	
	if (placed == false) :
		for room in specials :
			var position : Vector2i = Vector2i(Globals.chunkSize.x / 2, Globals.chunkSize.y / 2) - Vector2i(room.room_size.x / 2, room.room_size.y / 2)
			if (TryPlaceRoom(position, room)) :
				placed = true
				break
	
	if (placed == false) :
		var firstRoom : RoomResource = a_roomList.pick_random()
		if (firstRoom == null) :
			printerr("Chunk Generation error : First room is null")
			return false
	
		var position : Vector2i = Vector2i(Globals.chunkSize.x / 2, Globals.chunkSize.y / 2) - Vector2i(firstRoom.room_size.x / 2, firstRoom.room_size.y / 2)
		if (!TryPlaceRoom(position, firstRoom)) :
			printerr("Chunk Generation error : First room is invalid")
			return false
	#endregion
	
	var iteration = 0 # Debug purpose only
	var shuffledRooms : Array[RoomResource] = a_roomList
	shuffledRooms.append(specials)
	var aimPos : Vector2i = Vector2i(-10, -10)
	while (roadsAvailables.size() > 0 && iteration < 10000) :
		iteration += 1
		placed = false
		shuffledRooms.shuffle()
		
		#region Link Exits
		if !chunkExitsLinked.is_empty() : #Condition rajouter à la dernière minute
			for exitTile in chunkExitsLinked :
				placed = false
				shuffledRooms.shuffle()
				
				var target = GetTilesFacingExit(chunkExitsLinked[exitTile], chunkExits[chunkExitsLinked[exitTile]])
				print(target[exitTile])
				
				for room in shuffledRooms :
					if (room.NumbOfExits() >= 3
					&& room.allExits & target[exitTile]
					&& TryPlaceRoomBySize(exitTile, room)) :
						placed = true
						print(room.allExits)
						break
				if (placed == false) :
					for room in shuffledRooms :
						if (room.allExits & target[exitTile]
						&& TryPlaceRoomBySize(exitTile, room)) :
							placed = true
							print(room.allExits)
							break
		#endregion
		#region Fill Left Roads
		else :
			var nextPos = roadsAvailables.keys().pick_random()
			var startDir = roadsAvailables[nextPos]
			
			for room in shuffledRooms :
				if (room.allExits & startDir && TryPlaceRoomBySize(nextPos, room)) :
					placed = true
					break
			
			if (placed == false) :
				for room in WorldGen.GetBiomeDeadEnd(chunkBiome) :
					if (TryPlaceRoomBySize(nextPos, room)) :
						placed = true
						break
		#endregion
	
	#region Fill the gaps
	iteration = 0
	while (roomTiles.size() < Globals.chunkSize.x * Globals.chunkSize.y && iteration < 3) :
		iteration += 1
		for x in Globals.chunkSize.x :
			for y in Globals.chunkSize.y :
				if (!roomTiles.has(Vector2i(x, y))) :
					placed = false
					for room in shuffledRooms :
						if (TryPlaceRoomBySize(Vector2i(x, y), room)) :
							placed = true
							break
					if (placed == false) :
						for room in WorldGen.GetBiomeDeadEnd(chunkBiome) :
							if (TryPlaceRoomBySize(Vector2i(x, y), room)) :
								placed = true
								break
					if (placed == false) :
						TryPlaceRoomBySize(Vector2i(x, y), WorldGen.GetBiomeNoRoads(chunkBiome).pick_random())
	#endregion
	
	if (iteration >= 3) :
		printerr("Chunk Generation Error : Cannot generate the required numbers of tiles")
	
	return true

func IsOccupied(a_roomTilePos : Vector2i, a_roomSize : Vector2i = Vector2i(1, 1)) -> bool :
	for i in range(0, a_roomSize.x):
		for j in range(0, a_roomSize.y):
			var target = Vector2i(a_roomTilePos.x + i, a_roomTilePos.y + j)
			if (!_IsTileInside(target) || roomTiles.has(target)):
				return true
	
	return false

func IsPositionable(a_roomTilePos : Vector2i, a_room : RoomResource) -> bool :
	
	var tiles : Dictionary[Vector2i, int] = {}
	
	for exit in a_room.exits :
		tiles.merge(GetTilesFacingExit(exit, a_room.exits[exit]), true)
	
	for tile in tiles :
		var tilePos = tile + a_roomTilePos
		if (!_IsTileInside(tilePos)) :
			if (chunkExits.has(tilePos) == false) :
				return false
			elif (chunkExits.get(tilePos) != tiles[tile]) :
				return false
		elif (roomTiles.has(tilePos)) :
			if (!roomTiles.get(tilePos).getExits(tilePos) & tiles[tile]) :
				return false
	
	tiles.clear()
	for y in a_room.room_size.y :
		if (roomTiles.has(a_roomTilePos + Vector2i(-1, y))) :
			var room = roomTiles.get(a_roomTilePos + Vector2i(-1, y))
			tiles.set(a_roomTilePos + Vector2i(-1, y), room.getExits(a_roomTilePos + Vector2i(-1, y)))
		if (roomTiles.has(a_roomTilePos + Vector2i(a_room.room_size.x, y))) :
			var room = roomTiles.get(a_roomTilePos + Vector2i(a_room.room_size.x, y))
			tiles.set(a_roomTilePos + Vector2i(a_room.room_size.x, y), room.getExits(a_roomTilePos + Vector2i(a_room.room_size.x, y)))
	
	for x in a_room.room_size.x :
		if (roomTiles.has(a_roomTilePos + Vector2i(x, -1))) :
			var room = roomTiles.get(a_roomTilePos + Vector2i(x, -1))
			tiles.set(a_roomTilePos + Vector2i(x, -1), room.getExits(a_roomTilePos + Vector2i(x, -1)))
		if (roomTiles.has(a_roomTilePos + Vector2i(x, a_room.room_size.y))) :
			var room = roomTiles.get(a_roomTilePos + Vector2i(x, a_room.room_size.y))
			tiles.set(a_roomTilePos + Vector2i(x, a_room.room_size.y), room.getExits(a_roomTilePos + Vector2i(x, a_room.room_size.y)))
	
	for tile in tiles :
		var target = GetTilesFacingExit(tile, tiles[tile])
		
		for current in target :
			if (a_room.exits.has(current - a_roomTilePos) &&
			!a_room.exits.get(current - a_roomTilePos) & target[current]) :
				return false
	
	return true

func CanConnect(a_posA : Vector2i, a_roadA : int, a_posB : Vector2i, a_roadB : int) -> bool :
	
	if (a_roadA & GetDir(a_posA, a_posB) && a_roadB & GetDir(a_posB, a_posA)) :
		return true
	elif (!a_roadA & GetDir(a_posA, a_posB) && !a_roadB & GetDir(a_posB, a_posA)) :
		return true
	
	return false

func TryPlaceRoomBySize(a_roomTilePos : Vector2i, a_room : RoomResource) -> bool :
	for x in a_room.room_size.x :
		for y in a_room.room_size.y :
			if (TryPlaceRoom(Vector2i(a_roomTilePos.x - x, a_roomTilePos.y - y), a_room)) :
				return true
	
	return false

func TryPlaceRoom(a_roomTilePos : Vector2i, a_room : RoomResource) -> bool :
	
	if (IsOccupied(a_roomTilePos, a_room.room_size) || !IsPositionable(a_roomTilePos, a_room)):
		#print("Room Gen Stop : Room does not fit")
		return false
	#print("Room Gen Info : Room does fit, creating instance...")
	
	var loadedRoomBase = preload(Globals.RoomScnPath)
	var roomInstance : RoomData = loadedRoomBase.instantiate()
	self.add_child(roomInstance)
	
	roomInstance.currentPos = a_roomTilePos
	roomInstance.name = str(roomInstance.currentPos) + a_room.room_name
	roomInstance.position = Vector2((a_roomTilePos.x * Globals.GetPixelRoomSize().x),
	-(a_roomTilePos.y * Globals.GetPixelRoomSize().y) - (a_room.room_size.y * Globals.GetPixelRoomSize().y))
	roomInstance.load_room_data(a_room)
	
	#print("Room Gen Info : Room Instance '", roomInstance.name, "' created at (", roomInstance.position.x, ", ", roomInstance.position.y, ")")
	
	for i in range(0, roomInstance.roomSize.x):
		for j in range(0, roomInstance.roomSize.y):
			var pos = Vector2i(roomInstance.currentPos.x + i, roomInstance.currentPos.y + j)
			roomTiles.set(pos, roomInstance)
			if(chunkExitsLinked.has(pos)) :
				chunkExitsLinked.erase(pos)
			if(roadsAvailables.has(pos)) :
				roadsAvailables.erase(pos)
	
	roadsAvailables.merge(GetTilesFromExits(roomInstance))
	
	var index = 0
	for end in roomInstance.QuestEndList :
		end.global_position = roomInstance.global_position + a_room.quest_end_list.find_key(index)
		index += 1
	
	if (roomInstance.isImportantBuilding) :
		WorldGen.SetSpecialsQuestEnd(roomInstance)
	
	return true

func GetTilesFacingExit(a_pos : Vector2i, a_dir : int) -> Dictionary[Vector2i, int] :
	var result :  Dictionary[Vector2i, int] = {}
	
	if (a_dir & 1 << 0) :
		result.set(a_pos + Vector2i(-1, 0), 1 << 1)
	if (a_dir & 1 << 1) :
		result.set(a_pos + Vector2i(1, 0), 1 << 0)
	if (a_dir & 1 << 2) :
		result.set(a_pos + Vector2i(0, 1), 1 << 3)
	if (a_dir & 1 << 3) :
		result.set(a_pos + Vector2i(0, -1), 1 << 2)
	
	return result

func GetPosFacingExit(a_pos : Vector2i, a_dir : int) -> Vector2i :
	var result : Vector2i = Vector2i.ZERO
	
	if (a_dir & 1 << 0) :
		result = a_pos + Vector2i(-1, 0)
	elif (a_dir & 1 << 1) :
		result = a_pos + Vector2i(1, 0)
	elif (a_dir & 1 << 2) :
		result = a_pos + Vector2i(0, 1)
	elif (a_dir & 1 << 3) :
		result = a_pos + Vector2i(0, -1)
	
	return result

func GetTilesFromExits(a_room : RoomData) -> Dictionary[Vector2i, int] :
	
	var targetTiles : Dictionary[Vector2i, int] = {}
	for exit in a_room.exits :
		targetTiles.merge(GetTilesFacingExit(exit + a_room.currentPos, a_room.exits[exit]))
	
	#This variable exist because when erasing an element in a for loop, it skips the next element
	var toErase : Array[Vector2i] = []
	for tile in targetTiles :
		if (IsOccupied(tile)) :
			toErase.append(tile)
		elif (roadsAvailables.get(tile, -1) >= 0 && !(roadsAvailables.get(tile, -1) & targetTiles[tile])) :
			roadsAvailables[tile] = roadsAvailables[tile] + targetTiles[tile]
			toErase.append(tile)
	
	for tile in toErase :
		targetTiles.erase(tile)
	
	return targetTiles

func GetClosestAvailableRoad(a_pos : Vector2i, a_ignoreSelf : bool = false) -> Vector2i :
	var result : Vector2i = Vector2i.ZERO
	var minDistance : float = 10000000 #infinity equivalent
	
	for road in roadsAvailables :
		if ((a_pos - road).length() < minDistance && (!a_ignoreSelf || (a_pos - road).length() != 0)) :
			result = road
			minDistance = (a_pos - road).length()
	
	return result

func GetDir(a_start : Vector2i, a_target : Vector2i) -> int :
	var dirVector : Vector2i = a_target - a_start
	
	if (dirVector.abs().x >= dirVector.abs().y && dirVector.x >= 0 && !IsOccupied(a_start + Vector2i(1, 0))) :
		return 1 << 1
	elif (dirVector.abs().x >= dirVector.abs().y && dirVector.x < 0 && !IsOccupied(a_start + Vector2i(-1, 0))) :
		return 1 << 0
	elif (dirVector.y >= 0 && !IsOccupied(a_start + Vector2i(0, 1))) :
		return 1 << 2
	elif (dirVector.y < 0 && !IsOccupied(a_start + Vector2i(0, -1))) :
		return 1 << 3
	
	return 0

func GetClosestQuestEnd(a_pos : Vector2, a_exitType : Globals.EXIT_TYPES) -> QuestEnd :
	var target : QuestEnd = null
	
	var tile : RoomData = roomTiles.get(_GetTilePosFromGlobalPos(a_pos))
	if (tile != null) :
		target = tile.GetClosestQuestEnd(a_pos, a_exitType)
	
	if (target == null) :
		var distance : float = -1
		for room in roomTiles :
			var current : QuestEnd = roomTiles[room].GetClosestQuestEnd(a_pos, a_exitType)
			
			if (current != null && (distance == -1 || (a_pos - current.global_position).length() < distance)) :
				distance = (a_pos - current.global_position).length() 
				target = current
	
	return target
