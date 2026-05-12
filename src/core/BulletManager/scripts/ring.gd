extends Node2D
class_name  Ring

var ring_bullet = preload("res://src/core/BulletManager/scripts/light_ball.gd" )


#可调参数
var bullet_count:int = 32
var r:float = 50.0

var spawn_time:float = 0.8
var angle := TAU / bullet_count
var direction := Vector2.DOWN

var bulletpool :Node

func spawn_circle(target_pos:Array):
	for _target_pos in target_pos:
		for i in range(bullet_count):
			var theta = i * angle
			var pos = _target_pos + Vector2(r * cos(theta), r* sin(theta) )
			var tween = create_tween()
			var b = ring_bullet.instantiate()
			#b.rotation_degrees += rad_to_deg(theta) 
			tween.tween_property(b,"position",pos,spawn_time).from(_target_pos).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			b.init_speed = 1
			b.final_speed = 3
			b.acceleration = (b.final_speed - b.init_speed)/0.5
			b.direction = pos - _target_pos
			bulletpool.add_child(b)
