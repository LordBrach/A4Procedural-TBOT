@tool
extends Node2D

var boolenabled : bool = true
var dir:Vector2
var intensity:float = 1

func _on_body_entered(body:Node2D) -> void:
	print("collision")
	if (body is Player && boolenabled == true):
		Player.Instance.on_runoverclient()
		boolenabled = false
		dir = -(body.position - self.position).normalized()
		intensity = PlayerGlobal.velocity.length() * 1.5
		$AudioStreamPlayer2D.play()
		$DelaybeforeDeath.start()
		return
		
func _physics_process(delta: float) -> void:
	if(boolenabled == false):
		if($DelaybeforeDeath.time_left > 0):
			self.position += dir * intensity * delta
			self.rotation += (intensity/3) * delta
		else:
			queue_free()
