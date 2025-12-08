class_name QuestEnd extends CollectibleBase

var isActive: bool = false;

@export var PossibleDestinations : Array[Globals.EXIT_TYPES] = [Globals.EXIT_TYPES.Any]
@export var LinkedClientId:int = 0;
func on_collect() -> void:
	super()
	# end quest
	print("Terminated quest");
	# add points to player
	# spawn customer in map (?)

func _on_body_entered(body:Node2D) -> void:
	if(isActive) :
		if(Player.Instance.CustomerList.has(LinkedClientId)):
			Player.Instance.ComlpeteQuest(LinkedClientId)
			super(body)
	else:
		print("No quest linked to this quest end area");

func activate(client_id :int) ->void:
	isActive = true
	LinkedClientId = client_id
	
	
	
