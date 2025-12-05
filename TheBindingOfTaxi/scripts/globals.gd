extends Node
enum Directions {NONE = 0, WEST = 1 << 0, EAST = 1 << 1, NORTH = 1 << 2, SOUTH = 1 << 3}
@export var chunkSize : Vector2i = Vector2i(9, 9) #9 by default
@export var roomSize : Vector2i = Vector2i(17, 17) #17 by default
@export var tileSize : Vector2i = Vector2(16, 16) #16 following the TileSet indication
@export var chunkExitsRange : Vector2i = Vector2i(1, 2) #Between 1 and 3 exits by side

const RoomScnPath : String = "res://TheBindingOfTaxi/scenes/proto/cityroomtest.tscn"
const ChunkScnPath : String = "res://TheBindingOfTaxi/scenes/proto/Chunk.tscn"
#@export_flags("WEST", "NORTH", "SOUTH", "EAST") var DirectionTest : int = 0;

func _GetPixelChunkSize() -> Vector2 :
	return chunkSize * roomSize * tileSize

func _GetPixelRoomSize() -> Vector2 :
	return roomSize * tileSize
