@tool
extends Node2D

var boolenabled : bool = true

func hit(dir:Vector2, intensity:float):
	$DelaybeforeDeath.start()
	while($DelaybeforeDeath.time_left > 0):
		self.position += dir * intensity
		self.rotation += 5
		await get_tree().create_timer(0.01).timeout
	queue_free()
	
func _on_body_entered(body:Node2D) -> void:
	print("collision")
	if (body is Player && boolenabled == true):
		Player.Instance.on_runoverclient()
		boolenabled = false
		var directionvector : Vector2 = -(body.position - self.position)
		hit(directionvector, 1.0)
		return
