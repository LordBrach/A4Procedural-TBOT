class_name WorldGenManager extends Node2D

enum Biomes { None, Biome1, Biome2 }

@export var chunksTiles : Dictionary[Vector2i, Chunk] = {}

@export_category("Rooms")
@export var specialsBiome : Dictionary[RoomResource, Biomes]
@export var typeSpecials : Dictionary[RoomResource, Globals.EXIT_TYPES]
var existingSpecials : Array[RoomData]

@export_group("Regular Rooms")
@export var biome1Rooms : Array[RoomResource]
@export var biome2Rooms : Array[RoomResource]

@export_group("Dead Ends Rooms")
@export var biome1DeadEnds : Array[RoomResource]
@export var biome2DeadEnds : Array[RoomResource]

@export_group("NoRoads Rooms")
@export var biome1NoRoads : Array[RoomResource]
@export var biome2NoRoads : Array[RoomResource]

var last_Player_Pos : Vector2i = Vector2i(1000, 1000)

func _ready() -> void:
	CreateChunk(Vector2i.ZERO, Biomes.Biome1)

func _process(delta: float) -> void:
	
	var playerChunkPos = WorldToChunkPos(PlayerGlobal.global_position) #Position du player
	if (last_Player_Pos != playerChunkPos) :
		for x in range(-1, 2) :
			for y in range(-1, 2) :
				if (!chunksTiles.has(Vector2i(x, y))) :
					CreateChunk(Vector2i(x, y), Biomes.Biome1)
	
	last_Player_Pos = playerChunkPos

func WorldToChunkPos(a_pos : Vector2) -> Vector2i :
	
	var center = chunksTiles[Vector2i(0, 0)].position
	var result = (a_pos - center) / Globals.GetPixelChunkSize()

	return Vector2i(result.x, result.y)

func CreateChunk(a_pos : Vector2i, a_biome : Biomes) -> void :
	var chunk = preload(Globals.ChunkScnPath)
	var instance : Chunk = chunk.instantiate()
	self.add_child(instance)
	
	instance.StartGeneration(a_pos, a_biome)
	chunksTiles.set(a_pos, instance)

func CreateChunkSpecialRoom(a_pos : Vector2i, a_room : RoomResource) -> void :
	var chunk = preload(Globals.ChunkScnPath)
	var instance : Chunk = chunk.instantiate()
	self.add_child(instance)
	
	if (a_room == null) :
		printerr("Generate Chunk Error : The given room to generate is null")
		return
	var biome = specialsBiome.get(a_room, Biomes.None)
	if (biome == Biomes.None) :
		printerr("Generate Chunk Error : the given room '", a_room.room_name, "' didn't have an associated biome")
	
	instance.StartGeneration(a_pos, biome, a_room)
	chunksTiles.set(a_pos, instance)

func Getchunk(a_pos : Vector2i) -> Chunk :
	return chunksTiles.get(a_pos, null)

func GetAllConnections(a_pos : Vector2i) -> Dictionary[Vector2i, int] :
	var result : Dictionary[Vector2i, int] = {}
	result.merge(GetChunkConnections(a_pos, a_pos + Vector2i.LEFT))
	result.merge(GetChunkConnections(a_pos, a_pos + Vector2i.RIGHT))
	result.merge(GetChunkConnections(a_pos, a_pos + Vector2i.DOWN))
	result.merge(GetChunkConnections(a_pos, a_pos + Vector2i.UP))
	return result

func GetChunkConnections(a_selfPos : Vector2i, a_targetPos : Vector2i) -> Dictionary[Vector2i, int] :
	var result : Dictionary[Vector2i, int] = {}
	
	var chunk = Getchunk(a_targetPos)
	if (chunk != null) :
		match a_targetPos - a_selfPos :
			Vector2i.LEFT :
				var catch = chunk.GetExits(Globals.Directions.EAST)
				for exit in catch :
					result.set(Vector2i(Globals.chunkSize.x, exit.y), Globals.Directions.WEST as int)
			Vector2i.RIGHT :
				var catch = chunk.GetExits(Globals.Directions.WEST)
				for exit in catch :
					result.set(Vector2i(-1, exit.y), Globals.Directions.EAST as int)
			Vector2i.UP :
				var catch = chunk.GetExits(Globals.Directions.NORTH)
				for exit in catch :
					result.set(Vector2i(exit.x, Globals.chunkSize.y), Globals.Directions.SOUTH as int)
			Vector2i.DOWN :
				var catch = chunk.GetExits(Globals.Directions.SOUTH)
				for exit in catch :
					result.set(Vector2i(exit.x, -1), Globals.Directions.NORTH as int)
	
	return result

func GetBiomeNoRoads(a_biome : Biomes) -> Array[RoomResource] :
	match a_biome :
		Biomes.Biome1 :
			return biome1NoRoads
		Biomes.Biome2 :
			return biome2NoRoads
			
		_:
			return biome1NoRoads

func GetBiomeDeadEnd(a_biome : Biomes) -> Array[RoomResource] :
	match a_biome :
		Biomes.Biome1 :
			return biome1DeadEnds
		Biomes.Biome2 :
			return biome2DeadEnds
			
		_:
			return biome1DeadEnds

func GetRooms(a_biome : Biomes) -> Array[RoomResource] :
	var result : Array[RoomResource] = []
	
	match a_biome :
		Biomes.Biome1 :
			result = biome1Rooms
		Biomes.Biome2 :
			result = biome2Rooms
	
	return result

func GetSpecialsBiome(a_biome : Biomes) -> Array[RoomResource] :
	var result : Array[RoomResource] = []
	
	for room in specialsBiome :
		if (specialsBiome[room] == a_biome) :
			result.append(room)
	
	return result

func GetSpecialsExitType(a_exit : Globals.EXIT_TYPES) -> Array[RoomResource] :
	var result : Array[RoomResource] = []
	
	for room in specialsBiome :
		if (specialsBiome[room] == a_exit) :
			result.append(room)
	
	return result

func GetExistingSpecial(a_data : RoomResource) -> Array[RoomData] :
	var rooms : Array[RoomData] = []
	
	for special in existingSpecials :
		if (special.roomName == a_data.room_name) :
			rooms.append(special)
	
	return rooms

func SetSpecialsQuestEnd(a_data : RoomData) -> void :
	existingSpecials.append(a_data)
	return

func GetQuestEnd(a_customer : Customer, a_clientID : int) -> Vector2 :
	var destination : QuestEnd = null
	var exit : Globals.EXIT_TYPES = a_customer.SelectedDestination
	
	if (exit == Globals.EXIT_TYPES.Any || 
	exit == Globals.EXIT_TYPES.Parking ||
	exit == Globals.EXIT_TYPES.Bench ||
	exit == Globals.EXIT_TYPES.House) :
		var distance : Globals.DIFFICULTY_OPTIONS = a_customer.SelectedDifficulty
		var target = PlayerGlobal.global_position + Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * distance
		
		var chunkTarget : Vector2i = WorldToChunkPos(target)
		if (chunksTiles.has(chunkTarget)) :
			destination = chunksTiles[chunkTarget].GetClosestQuestEnd(target, exit)
		else :
			CreateChunk(chunkTarget, Globals.GetRandomBiome())
			destination = chunksTiles[chunkTarget].GetClosestQuestEnd(target, exit)
	else :
		var rooms = GetSpecialsExitType(exit)
		var list : Array[RoomData] = []
		for room in rooms :
			list.append_array(GetExistingSpecial(room))
		
		if (list.is_empty()) :
			if (Vector2i.ZERO == GenerateClosestChunk(last_Player_Pos, rooms.pick_random())) :
				printerr("Get QuestEnd Error : Cannot generate a chunk for QuestEnd of type '", exit, "'")
				return Vector2.ZERO
			for room in rooms :
				list.append_array(GetExistingSpecial(room))
		
		var distance : float = -1
		for room in list :
			var target : QuestEnd = room.GetClosestQuestEnd(PlayerGlobal.global_position, exit)
			if (distance == -1 || distance > (target.global_position - PlayerGlobal.global_position). length()) :
				distance = (target.global_position - PlayerGlobal.global_position).length()
				destination = target
	
	if (destination != null) :
		destination.activate(a_clientID)
		print("Destination : ", destination.global_position, " - ", destination.name)
		return destination.global_position
	else :
		printerr("Get QuestEnd Error : No quest end found")
		return Vector2.ZERO

func GenerateClosestChunk(a_pos : Vector2i, a_room : RoomResource) -> Vector2i :
	var toVerify : Array[Vector2i] = []
	
	toVerify.append_array([
		a_pos + Vector2i.UP,
		a_pos + Vector2i.LEFT,
		a_pos + Vector2i.DOWN,
		a_pos + Vector2i.RIGHT
	])
	
	for chunk in toVerify :
		if (!chunksTiles.has(chunk)) :
			CreateChunkSpecialRoom(chunk, a_room)
			return chunk
		
		if (!toVerify.has(a_pos + Vector2i.UP)) :
			toVerify.append(a_pos + Vector2i.UP)
		if (!toVerify.has(a_pos + Vector2i.LEFT)) :
			toVerify.append(a_pos + Vector2i.LEFT)
		if (!toVerify.has(a_pos + Vector2i.DOWN)) :
			toVerify.append(a_pos + Vector2i.DOWN)
		if (!toVerify.has(a_pos + Vector2i.RIGHT)) :
			toVerify.append(a_pos + Vector2i.RIGHT)
	
	#for security
	return Vector2i.ZERO
