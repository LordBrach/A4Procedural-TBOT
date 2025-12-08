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
			var pos : int = randi_range(0, Globals.chunkSize.y - 1)
			chunkExits.get_or_add(Vector2i(Globals.chunkSize.x, pos), 1 << 0)
	if (chunkExits.find_key(1 << 1) == null) :
		var rand : int = randi_range(Globals.chunkExitsRange.x, Globals.chunkExitsRange.y)
		for x in range(rand) :
			var pos : int = randi_range(0, Globals.chunkSize.y - 1)
			chunkExits.get_or_add(Vector2i(-1, pos), 1 << 1)
	if (chunkExits.find_key(1 << 2) == null) :
		var rand : int = randi_range(Globals.chunkExitsRange.x, Globals.chunkExitsRange.y)
		for x in range(rand) :
			var pos : int = randi_range(0, Globals.chunkSize.x - 1)
			chunkExits.get_or_add(Vector2i(pos, -1), 1 << 2)
	if (chunkExits.find_key(1 << 3) == null) :
		var rand : int = randi_range(Globals.chunkExitsRange.x, Globals.chunkExitsRange.y)
		for x in range(rand) :
			var pos : int = randi_range(0, Globals.chunkSize.x - 1)
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
			if (chunkExits[exit] & 1 << 1) :
				list.set(exit, chunkExits[exit])
	elif (dirNum & 1 << 1) :
		for exit in chunkExits :
			if (chunkExits[exit] & 1 << 0) :
				list.set(exit, chunkExits[exit])
	elif (dirNum & 1 << 2) :
		for exit in chunkExits :
			if (chunkExits[exit] & 1 << 3) :
				list.set(exit, chunkExits[exit])
	elif (dirNum & 1 << 3) :
		for exit in chunkExits :
			if (chunkExits[exit] & 1 << 2) :
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
	
	if (!(a_pos.x >= 0 && a_pos.x < Globals.chunkSize.x)) :
		result = false
	elif (!(a_pos.y >= 0 && a_pos.y < Globals.chunkSize.x)) :
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
		SetExits()
		Generation(roomlist)
	else :
		print("Chunk Generation error : WorldGenManager instance not found")

func Generation(a_roomList : Array[RoomResource]) -> void :
	
	var firstRoom : RoomResource = a_roomList.pick_random()
	if (firstRoom == null) :
		print("Chunk Generation error : First room is null")
		return
	
	var position : Vector2i = Vector2i(Globals.chunkSize.x / 2, Globals.chunkSize.y / 2) - Vector2i(firstRoom.room_size.x / 2, firstRoom.room_size.y / 2)
	
	if (!TryPlaceRoom(position, firstRoom)) :
		print("Chunk Generation error : First room is invalid")
	
	var iteration = 0 # Debug purpose only
	var shuffledRooms : Array[RoomResource] = a_roomList
	var aimPos : Vector2i = Vector2i(-10, -10)
	while (roadsAvailables.size() > 0 && iteration < 10000) :
		iteration += 1
		
		#if (aimPos == Vector2i(-10, -10) && !chunkExitsLinked.is_empty()) :
			#var values = chunkExitsLinked.values()
			#aimPos = chunkExitsLinked.find_key(values.pick_random())
		
		shuffledRooms.shuffle()
		var placed : bool = false
		
		if (aimPos !=  Vector2i(-10, -10)) :
			var nextPos = GetClosestAvailableRoad(aimPos)
			var startDir = roadsAvailables[nextPos]
			var aimDir : int = GetDir(nextPos, aimPos)
			
			if (aimDir == 0) :
				for deadEnd in WorldGen.GetBiomeDeadEnd(chunkBiome) :
					if (TryPlaceRoomBySize(nextPos, deadEnd)) :
						placed = true
						break
			else :
				for room in shuffledRooms :
					if (room.allExits & startDir && room.allExits & aimDir &&
					TryPlaceRoomBySize(nextPos, room)) :
						placed = true
						break
			
			if (IsOccupied(aimPos)) :
				aimPos = Vector2i(-10, -10)
		elif !chunkExitsLinked.is_empty() : #Condition rajouter à la dernière minute
			for exitTile in chunkExitsLinked :
				shuffledRooms.shuffle()
				for room in shuffledRooms :
					if (room.allExits & chunkExits[chunkExitsLinked[exitTile]]
					&& TryPlaceRoomBySize(exitTile, room)) :
						placed = true
						break
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
		
	
	for x in Globals.chunkSize.x :
		for y in Globals.chunkSize.y :
			if (!IsOccupied(Vector2i(x, y))) :
				TryPlaceRoom(Vector2i(x, y), WorldGen.GetBiomeNoRoads(chunkBiome).pick_random())
	
	return

func IsOccupied(a_roomTilePos : Vector2i, a_roomSize : Vector2i = Vector2i(1, 1)) -> bool :
	for i in range(0, a_roomSize.x):
		for j in range(0, a_roomSize.y):
			var target = Vector2i(a_roomTilePos.x + i, a_roomTilePos.y + j)
			if (!_IsTileInside(target) || roomTiles.has(target)):
				return true
	
	return false

func IsPositionable(a_roomTilePos : Vector2i, a_room : RoomResource) -> bool :
	
	#region method2
	#var west_x = - 1
	#var east_x = a_room.room_size.x
	#for y in a_room.room_size.y :
		#var localPos = Vector2i(0, y)
		#var adjacent = Vector2i(west_x, y)
		#
		#var tile = roomTiles.get(adjacent + a_roomTilePos, null)
		#var exit = chunkExits.get(adjacent + a_roomTilePos, null)
		#if (tile != null) :
			#if (!CanConnect(localPos, a_room.exits.get(localPos, 0),
			#adjacent, tile.exits.get((adjacent + a_roomTilePos) - tile.currentPos))) : return false
		#elif (exit != null) :
			#if (!CanConnect(localPos, a_room.exits.get(localPos, 0),
			#adjacent, exit)) : return false
		#elif (a_room.exits[localPos] & GetDir(localPos, adjacent) && _IsPosInside(adjacent + a_roomTilePos)) :
			#return false
		#
		#
		#localPos = Vector2i(east_x - 1, y)
		#adjacent = Vector2i(east_x, y)
		#
		#tile = roomTiles.get(adjacent + a_roomTilePos, null)
		#exit = chunkExits.get(adjacent + a_roomTilePos, null)
		#if (tile != null) :
			#if (!CanConnect(localPos, a_room.exits.get(localPos, 0),
			#adjacent, tile.exits.get((adjacent + a_roomTilePos) - tile.currentPos))) : return false
		#elif (exit != null) :
			#if (!CanConnect(localPos, a_room.exits.get(localPos, 0),
			#adjacent, exit)) : return false
		#elif (a_room.exits[localPos] & GetDir(localPos, adjacent) && _IsPosInside(adjacent + a_roomTilePos)) :
			#return false
	#
	#var south_y = - 1
	#var north_y = a_room.room_size.y
	#for x in a_room.room_size.x :
		#var localPos = Vector2i(x, 0)
		#var adjacent = Vector2i(x, south_y)
		#
		#var tile = roomTiles.get(adjacent + a_roomTilePos, null)
		#var exit = chunkExits.get(adjacent + a_roomTilePos, null)
		#if (tile != null) :
			#if (!CanConnect(localPos, a_room.exits.get(localPos, 0),
			#adjacent, tile.exits.get((adjacent + a_roomTilePos) - tile.currentPos))) : return false
		#elif (exit != null) :
			#if (!CanConnect(localPos, a_room.exits.get(localPos, 0),
			#adjacent, exit)) : return false
		#elif (a_room.exits[localPos] & GetDir(localPos, adjacent) && _IsPosInside(adjacent + a_roomTilePos)) :
			#return false
		#
		#
		#localPos = Vector2i(x, north_y - 1)
		#adjacent = Vector2i(x, north_y)
		#
		#tile = roomTiles.get(adjacent + a_roomTilePos, null)
		#exit = chunkExits.get(adjacent + a_roomTilePos, null)
		#if (tile != null) :
			#if (!CanConnect(localPos, a_room.exits.get(localPos, 0),
			#adjacent, tile.exits.get((adjacent + a_roomTilePos) - tile.currentPos))) : return false
		#elif (exit != null) :
			#if (!CanConnect(localPos, a_room.exits.get(localPos, 0),
			#adjacent, exit)) : return false
		#elif (a_room.exits[localPos] & GetDir(localPos, adjacent) && _IsPosInside(adjacent + a_roomTilePos)) :
			#return false
	#endregion
	
	#region method1
	for x in range(a_room.room_size.x) :
		var current = Vector2i(a_roomTilePos.x + x, a_roomTilePos.y)
		var target = current - Vector2i(0, 1)
		var tile = roomTiles.get(target)
		if (tile != null) :
			var tileExits = tile.getExits(target)
			if(!(tileExits & 1 << 2 && a_room.exits[current - a_roomTilePos] & 1 << 3) && 
			(tileExits & 1 << 2 || a_room.exits[current - a_roomTilePos] & 1 << 3)) :
				return false
		elif (chunkExits.get(target) != null && !(a_room.exits[current - a_roomTilePos] & 1 << 3)) :
			return false
		
		
		
		target = current + Vector2i(0, a_room.room_size.y)
		tile = roomTiles.get(target)
		if (tile != null) :
			var tileExits = tile.getExits(target)
			if(!(tileExits & 1 << 3 && a_room.exits[current - a_roomTilePos] & 1 << 2) && 
			(tileExits & 1 << 3 || a_room.exits[current - a_roomTilePos] & 1 << 2)) :
				return false
		elif (chunkExits.get(target) != null && !(a_room.exits[current - a_roomTilePos] & 1 << 2)) :
			return false
	
	for y in range(a_room.room_size.y) :
		var current = Vector2i(a_roomTilePos.x, a_roomTilePos.y + y)
		var target = current - Vector2i(1, 0)
		var tile = roomTiles.get(target)
		if (tile != null) :
			var tileExits = tile.getExits(target)
			if(!(tileExits & 1 << 1 && a_room.exits[current - a_roomTilePos] & 1 << 0) && 
			(tileExits & 1 << 1 || a_room.exits[current - a_roomTilePos] & 1 << 0)) :
				return false
		elif (chunkExits.get(target) != null && !(a_room.exits[current - a_roomTilePos] & 1 << 0)) :
			return false
		
		target = current + Vector2i(a_room.room_size.x, 0)
		tile = roomTiles.get(target)
		if (tile != null) :
			var tileExits = tile.getExits(target)
			if(!(tileExits & 1 << 0 && a_room.exits[current - a_roomTilePos] & 1 << 1) && 
			(tileExits & 1 << 0 || a_room.exits[current - a_roomTilePos] & 1 << 1)) :
				return false
		elif (chunkExits.get(target) != null && !(a_room.exits[current - a_roomTilePos] & 1 << 1)) :
			return false
	#endregion
	
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
			if (TryPlaceRoom(Vector2i(a_roomTilePos.x + x, a_roomTilePos.y + y), a_room)) :
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
	roomInstance.position = Vector2(position.x + (a_roomTilePos.x * Globals._GetPixelRoomSize().x), position.y + -(a_roomTilePos.y * Globals._GetPixelRoomSize().y))
	roomInstance.load_room_data(a_room)
	
	#print("Room Gen Info : Room Instance '", roomInstance.name, "' created at (", roomInstance.position.x, ", ", roomInstance.position.y, ")")
	
	for i in range(0, roomInstance.roomSize.x):
		for j in range(0, roomInstance.roomSize.y):
			var pos = Vector2i(roomInstance.currentPos.x + i, roomInstance.currentPos.y + j)
			roomTiles.set(pos, roomInstance)
			if(chunkExitsLinked.has(pos)) :
				chunkExitsLinked.erase(pos)
				print("erase chunk exits")
			if(roadsAvailables.has(pos)) :
				roadsAvailables.erase(pos)
	
	roadsAvailables.merge(GetTilesFromExits(roomInstance))
	
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
