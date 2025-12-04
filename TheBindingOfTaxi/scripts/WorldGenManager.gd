class_name WorldGenManager extends Node2D

enum Biomes { None, Biome1, Biome2, Biome3 }


@export var roomPixelSize : Vector2 = Vector2.ONE

@export var specialRooms : Dictionary[RoomData, Biomes]
var specialRoomsCount : Dictionary[RoomData, bool]

@export var biome1Rooms : Array[RoomData]
var biome1Count : Array[bool]
@export var biome2Rooms : Array[RoomData]
var biome2Count : Array[bool]
@export var biome3Rooms : Array[RoomData]
var biome3Count : Array[bool]

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

func GetRandomRoom(a_biome : Biomes, a_direction : Globals.Directions) -> String:
	
	return ""
