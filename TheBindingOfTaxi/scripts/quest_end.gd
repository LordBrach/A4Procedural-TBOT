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

@export var startAnimAlpha : float = 0.8
@export var animDuration : float = 2

var time : float = 0

func _ready() -> void:
	zoneSprite1.modulate = zoneColor
	zoneSprite2.modulate = zoneColor
	
	#if(!isAddedToPlayer) : 
		#Player.Instance.SavedExits.append(self)
		#isAddedToPlayer = true
	 #await get_tree().create_timer(1.0).timeout

func _process(delta: float) -> void:
	if (isActive) :
		time += delta
		
		var sprite1timer = time / animDuration

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
			#super(body)
	else:
		pass
		#print("No quest linked to this quest end area");

func activate(client_id :int) ->void:
	isActive = true
	LinkedClientId = client_id
	
	
	
