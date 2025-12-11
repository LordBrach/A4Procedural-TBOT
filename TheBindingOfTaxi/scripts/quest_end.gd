@tool
class_name QuestEnd extends CollectibleBase

var isActive: bool = false;
var isAddedToPlayer : bool = false

@export var PossibleDestinations : Array[Globals.EXIT_TYPES] = [Globals.EXIT_TYPES.Any]
@export var LinkedClientId:int = 0;

@export var hitbox : CollisionShape2D

@export var zoneColor : Color = Color.GREEN
@export var zoneSprite1 : Sprite2D
@export var zoneSprite2 : Sprite2D

@export var startAnimAlpha : float = 1
@export var animDuration : float = 2
@export var fullSize : float = 32

var time : float = 0

func _ready() -> void:
	zoneSprite1.modulate = zoneColor
	zoneSprite2.modulate = zoneColor
	zoneSprite1.modulate.a = 0
	zoneSprite2.modulate.a = 0

func _process(delta: float) -> void:
	if (isActive) :
		time += delta
		
		var sprite1timer : float = fmod(time, animDuration) / animDuration
		var sprite2timer : float = fmod(time - (animDuration / 2), animDuration) / animDuration
		
		zoneSprite1.scale = get_from_fullsize(sprite1timer)
		zoneSprite2.scale = get_from_fullsize(sprite2timer)
		zoneSprite1.modulate.a = startAnimAlpha - (startAnimAlpha * sprite1timer)
		zoneSprite2.modulate.a = startAnimAlpha - (startAnimAlpha * sprite2timer)

func get_from_fullsize(a_size : float) -> Vector2 :
	var result : Vector2
	
	result.x = (hitbox.shape.get_rect().size.x / fullSize) * a_size
	result.y = (hitbox.shape.get_rect().size.y / fullSize) * a_size
	return result

func on_collect() -> void:
	super()
	# end quest
	print("Terminated quest");
	# add points to player
	# spawn customer in map (?)

func _on_body_entered(body:Node2D) -> void:
	if !body is Player:
		return
		
	if(isActive) :
		if(Player.Instance.CustomerList.has(LinkedClientId)):
			Player.Instance.complete_quest(LinkedClientId)
			isActive = false
			zoneSprite1.modulate.a = 0
			zoneSprite2.modulate.a = 0
			#super(body)
	else:
		pass
		#print("No quest linked to this quest end area");

func activate(client_id :int) ->void:
	isActive = true
	LinkedClientId = client_id
	
	
	
