class_name WorldGenManager extends Node2D

enum Biomes { None, Biome1, Biome2, Biome3 }

@export var chunksTiles : Dictionary[Vector2i, Chunk] = {}

@export_category("Rooms")
@export var specialRooms : Dictionary[RoomResource, Biomes]
var specialRoomsCount : Dictionary[RoomResource, bool]

@export_group("Regular Rooms")
@export var biome1Rooms : Array[RoomResource]
@export var biome2Rooms : Array[RoomResource]
@export var biome3Rooms : Array[RoomResource]

@export_group("Dead Ends Rooms")
@export var biome1DeadEnds : Array[RoomResource]
@export var biome2DeadEnds : Array[RoomResource]
@export var biome3DeadEnds : Array[RoomResource]

@export_group("NoRoads Rooms")
@export var biome1NoRoads : Array[RoomResource]
@export var biome2NoRoads : Array[RoomResource]
@export var biome3NoRoads : Array[RoomResource]

func _ready() -> void:
	var chunk = preload(Globals.ChunkScnPath)
	var instance : Chunk = chunk.instantiate()
	self.add_child(instance)
	
	instance.StartGeneration(Vector2i.ZERO, Biomes.Biome1)

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
					result.set(Vector2i(-1, exit.y), Globals.Directions.EAST as int)
			Vector2i.RIGHT :
				var catch = chunk.GetExits(Globals.Directions.WEST)
				for exit in catch :
					result.set(Vector2i(Globals.chunkSize.x, exit.y), Globals.Directions.WEST as int)
			Vector2i.UP :
				var catch = chunk.GetExits(Globals.Directions.NORTH)
				for exit in catch :
					result.set(Vector2i(exit.x, -1), Globals.Directions.NORTH as int)
			Vector2i.DOWN :
				var catch = chunk.GetExits(Globals.Directions.SOUTH)
				for exit in catch :
					result.set(Vector2i(exit.x, Globals.chunkSize.y), Globals.Directions.SOUTH as int)
	
	return result

func GetBiomeNoRoads(a_biome : Biomes) -> Array[RoomResource] :
	match a_biome :
		Biomes.Biome1 :
			return biome1NoRoads
		Biomes.Biome2 :
			return biome2NoRoads
		Biomes.Biome3 :
			return biome3NoRoads
			
		_:
			return biome1NoRoads

func GetBiomeDeadEnd(a_biome : Biomes) -> Array[RoomResource] :
	match a_biome :
		Biomes.Biome1 :
			return biome1DeadEnds
		Biomes.Biome2 :
			return biome2DeadEnds
		Biomes.Biome3 :
			return biome3DeadEnds
			
		_:
			return biome1DeadEnds

func GetRooms(a_biome : Biomes) -> Array[RoomResource] :
	var result : Array[RoomResource] = []
	
	match a_biome :
		Biomes.Biome1 :
			result = biome1Rooms
		Biomes.Biome2 :
			result = biome2Rooms
		Biomes.Biome3 :
			result = biome3Rooms
	
	return result

func GetRandomImportant(a_biome : Biomes, a_direction : Globals.Directions) -> String:
	
	return ""
