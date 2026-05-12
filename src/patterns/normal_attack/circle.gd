extends Pattern
class_name CirclePattern

@export var count:int = 144
@export var ring_radius:float = 200.0
@export var expand_delay:float = 0.15
@export var expand_speed:float = 100.0
@export var expand_final_speed:float = 500.0
@export var expand_acceleration:float = 50.0

func spawn_cicle():

	for i in range(count):
		var angle = i * (TAU/count)
		var b = pool.pop_back()
		var dir = Vector2(cos(angle), sin(angle)).normalized()
		var pos = self.global_position + dir * ring_radius
		
		b.init_speed = 0.0
		b.final_speed = 0.0
		b.acceleration = 0.0
		b.direction = dir
		b.bullet_on(self.global_position)
		var tween = b.create_lifecycle_tween()
		tween.tween_property(b, "global_position", pos, 1.5).from(self.global_position).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.tween_interval(expand_delay)
		tween.tween_callback(Callable(self, "_expand_bullet").bind(b, dir))



func spawn():
	spawn_cicle()


func _expand_bullet(b: Bullet, dir: Vector2):
	if not is_instance_valid(b) or not b.visible:
		return
	b.direction = dir
	b.init_speed = expand_speed
	b.final_speed = expand_final_speed
	b.acceleration = expand_acceleration
	b.speed = expand_speed
