@tool
extends CollisionShape2D

func hit(dir:Vector2, intensity:float):
	$"../DelaybeforeDeath".start()
	while($"../DelaybeforeDeath".time_left > 0):
		self.position += dir * intensity
		self.rotation += 5
		await get_tree().create_timer(0.1).timeout
	queue_free()
	
func _on_body_entered(body:Node2D) -> void:
	if (body is Player && disabled == false):
		var directionvector = !(body.position - self.position)
		disabled = true
		hit(directionvector, 1.0)
		return
