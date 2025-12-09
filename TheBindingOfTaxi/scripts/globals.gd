extends Node
enum Directions {NONE = 0, WEST = 1 << 0, EAST = 1 << 1, NORTH = 1 << 2, SOUTH = 1 << 3}
@export var chunkSize : Vector2i = Vector2i(7, 7) #9 by default
@export var roomSize : Vector2i = Vector2i(21, 21) #17 by default
@export var tileSize : Vector2i = Vector2i(16, 16) #16 following the TileSet pixel size indication indication
@export var chunkExitsRange : Vector2i = Vector2i(1, 3) #Between 1 and 3 exits by side

const RoomScnPath : String = "res://TheBindingOfTaxi/scenes/proto/cityroomtest.tscn"
const ChunkScnPath : String = "res://TheBindingOfTaxi/scenes/proto/Chunk.tscn"
#@export_flags("WEST", "NORTH", "SOUTH", "EAST") var DirectionTest : int = 0;

enum CUSTOMER_TYPE { Default, Old , Gangster , Student , Balthazar }
enum DIFFICULTY_OPTIONS { SameRoom, Short, Medium , Long , ExtraLong}
enum EXIT_TYPES { Any, Parking, Bench, Park , House , Shop} 
enum DRIVING_CONDITIONS {None, Quick, Careful, HurtPeople, LawAbiding}
enum SPRITE_DIRECTION { UP, DOWN , LEFT , RIGHT , MISC }

func GetPixelChunkSize() -> Vector2 :
	return chunkSize * roomSize * tileSize

func GetPixelRoomSize() -> Vector2 :
	return roomSize * tileSize
