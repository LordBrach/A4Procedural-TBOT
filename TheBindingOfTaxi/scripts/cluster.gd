class_name Chunk extends Node2D

@export var chunkPosition : Vector2i

var roomTiles : Dictionary[Vector2i, Room]

@export var roomPixelSize : Vector2


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _GetChunkSize() -> Vector2 :
	return WorldGen.roomPixelSize * WorldGen.chunkSize

func _GetPositionFromRoomTile(a_roomTilePos : Vector2i) -> Vector2:
	var localPos = Vector2(a_roomTilePos.x * roomPixelSize.x, a_roomTilePos.y * roomPixelSize.y)
	var result : Vector2 = localPos + position
	return result

func _IsPosInside(a_pos : Vector2) -> bool:
	var result : bool = true
	
	if (!(position.x < a_pos.x && a_pos.x < position.x + _GetChunkSize().x)) :
		result = false
	elif (!(position.y < a_pos.y && a_pos.y < position.y + _GetChunkSize().y)) :
		result = false
	
	return result

func _IsTileInside(a_pos : Vector2i) -> bool :
	var result : bool = true
	
	if (!(0 < a_pos.x && a_pos.x < chunkSize)) :
		result = false
	elif (!(0 < a_pos.y && a_pos.y < chunkSize)) :
		result = false
	
	return result


func IsOccupied(a_roomTilePos : Vector2i, a_roomPixelSize : Vector2i = Vector2i(1, 1)) -> bool :
	for i in range(0, a_roomPixelSize.x):
		for j in range(0, a_roomPixelSize.y):
			var target = Vector2i(a_roomTilePos.x + i, a_roomTilePos.y + j)
			if (!_IsTileInside(target) || roomTiles.has(target)):
				return false
	
	return true

func IsPositionable(a_roomTilePos : Vector2i, a_room : Room) -> bool :
	
	#Verification des accès des routes avec IsAccessible()
	
	return false

func IsAccessible(a_roomTilePos : Vector2i, a_direction : int) -> bool :
	
	return false

func _TryPlaceRoom(a_roomTilePos : Vector2i, a_room : Room) -> bool :
	
	if (!IsOccupied(a_roomTilePos, a_room.room_size) || !IsPositionable(a_roomTilePos, a_room)):
		return false
	
	for i in range(0, a_room.room_size.x):
		for j in range(0, a_room.room_size.y):
			var pos = Vector2i(a_roomTilePos.x + i, a_roomTilePos.y + j)
			roomTiles.assign({pos : a_room})
	
	return true
