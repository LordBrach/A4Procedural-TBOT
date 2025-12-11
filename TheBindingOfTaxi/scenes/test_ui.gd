extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	# get_tree().change_scene_to_file(#put the game scene name in here)
	pass


func _on_options_pressed() -> void:
	# get_tree().change_scene_to_file(#put the option scene name if we make one, in here)
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
