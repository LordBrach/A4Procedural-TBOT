class_name WorldGenManager extends Node2D

enum Biomes { None, Biome1, Biome2, Biome3 }

@export var chunksTiles : Dictionary[Vector2i, Chunk] = {}

@export var specialRooms : Dictionary[RoomResource, Biomes]
var specialRoomsCount : Dictionary[RoomResource, bool]

@export var biome1Rooms : Array[RoomResource]
@export var biome2Rooms : Array[RoomResource]
@export var biome3Rooms : Array[RoomResource]

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
				var catch = chunk.GetExits(Globals.Directions.WEST)
				for exit in catch :
					result.set(exit + Vector2i.LEFT, Globals.Directions.EAST as int)
			Vector2i.RIGHT :
				var catch = chunk.GetExits(Globals.Directions.EAST)
				for exit in catch :
					result.set(exit + Vector2i.RIGHT, Globals.Directions.WEST as int)
			Vector2i.UP :
				var catch = chunk.GetExits(Globals.Directions.SOUTH)
				for exit in catch :
					result.set(exit + Vector2i.UP, Globals.Directions.NORTH as int)
			Vector2i.DOWN :
				var catch = chunk.GetExits(Globals.Directions.NORTH)
				for exit in catch :
					result.set(exit + Vector2i.DOWN, Globals.Directions.SOUTH as int)
	
	return result

#func _GetBiomeRoomSet(a_biome : Biomes) -> Array[String] :
	#match a_biome :
		#Biomes.Biome1 :
			#return biome1Rooms
		#Biomes.Biome2 :
			#return biome2Rooms
		#Biomes.Biome3 :
			#return biome3Rooms
			#
		#_:
			#return biome1Rooms

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
