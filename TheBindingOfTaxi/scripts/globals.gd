extends Node
enum Directions {NONE = 0, WEST = 1 << 0, EAST = 1 << 1, NORTH = 1 << 2, SOUTH = 1 << 3}
@export var chunkSize : Vector2i = Vector2i(7, 7) #9 by default
@export var roomSize : Vector2i = Vector2i(17, 17) #17 by default
@export var tileSize : Vector2i = Vector2i(16, 16) #16 following the TileSet pixel size indication indication
@export var chunkExitsRange : Vector2i = Vector2i(1, 3) #Between 1 and 3 exits by side

@export var distanceByDifficulty : Dictionary[DIFFICULTY_OPTIONS, float] = {
	DIFFICULTY_OPTIONS.SameRoom : 0.0,
	DIFFICULTY_OPTIONS.Short : 1000.0,
	DIFFICULTY_OPTIONS.Medium : 2000.0,
	DIFFICULTY_OPTIONS.Long : 3000.0,
	DIFFICULTY_OPTIONS.ExtraLong : 4000.0,
}

const RoomScnPath : String = "res://TheBindingOfTaxi/scenes/proto/cityroomtest.tscn"
const ChunkScnPath : String = "res://TheBindingOfTaxi/scenes/proto/Chunk.tscn"
#@export_flags("WEST", "NORTH", "SOUTH", "EAST") var DirectionTest : int = 0;

enum CUSTOMER_TYPE { Default, Old , Gangster , Student , Balthazar }
enum DIFFICULTY_OPTIONS { SameRoom, Short, Medium , Long , ExtraLong}
enum EXIT_TYPES { Any, Parking, Bench, House, Park, Lake , University, Shop} 
enum DRIVING_CONDITIONS {None, Quick, Careful, HurtPeople, LawAbiding}
enum SPRITE_DIRECTION { UP, DOWN , LEFT , RIGHT , MISC }

func GetPixelChunkSize() -> Vector2 :
	return chunkSize * roomSize * tileSize

func GetPixelRoomSize() -> Vector2 :
	return roomSize * tileSize

func GetRandomBiome() -> WorldGen.Biomes :
	var biome : WorldGen.Biomes
	var rand : int = randi_range(0, WorldGen.Biomes.size())
	
	match rand :
		0 : biome = WorldGen.Biomes.Biome1
		1 : biome = WorldGen.Biomes.Biome2
		2 : biome = WorldGen.Biomes.Biome3
		_ : biome = WorldGen.Biomes.Biome1
	
	return biome
