extends Bullet

var min_speed := 200.0
#var accel_time :=0.3
var decel_time := 1.5



# Called when the node enters the scene tree for the first time.

	
func bullet_on(pos:Vector2):
	super.bullet_on(pos)
	var tween =create_tween()
	tween.tween_property(self, "speed", speed, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "speed", min_speed, decel_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)




func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("boundary"):	
		queue_free()
	elif body is CharacterBody2D:
		body._hurt()
		queue_free()
