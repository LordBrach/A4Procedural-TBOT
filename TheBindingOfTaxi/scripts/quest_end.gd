class_name QuestEnd extends CollectibleBase

var isActive: bool = false;

func on_collect() -> void:
	super()
	# end quest
	print("Terminated quest");
	# add points to player
	# spawn customer in map (?)

func _on_body_entered(body:Node2D) -> void:
	if(isActive) :
		super(body)
	else:
		print("No quest linked to this quest end area");
