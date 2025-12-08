extends Node
enum Directions {NONE = 0, WEST = 1 << 0, EAST = 1 << 1, NORTH = 1 << 2, SOUTH = 1 << 3}
@export var chunkSize : Vector2i = Vector2i(9, 9)
@export var roomSize : Vector2i = Vector2i(17, 17)
#@export_flags("WEST", "NORTH", "SOUTH", "EAST") var DirectionTest : int = 0;

enum CUSTOMER_TYPE { Default, Old , Gangster , Student , Balthazar }
enum DIFFICULTY_OPTIONS { SameRoom, Short, Medium , Long , ExtraLong}
enum EXIT_TYPES { Any, Parking, Bench, Park , House , Shop} 
enum DRIVING_CONDITIONS {None, Quick, Careful, HurtPeople, LawAbiding}
