extends Pattern

@export_group("玫瑰图像设置")
@export var k := 11.0
@export var a := 400.0
@export var theta := 0.0
@export var r :float
@export var N :int = 480


func spawn_rose_bullet():
	for i in range(N):
		var b = pool.pop_back()
		theta = i * (TAU/N)
		r = a * sin( k * theta)
		b.init_speed = 100.0
		b.final_speed = 500.0
		b.acceleration = 120
		b.direction = Vector2( cos(theta) , sin(theta) ).normalized()
		b.bullet_on(self.global_position)
		var pos = self.global_position + Vector2( r*cos(theta) , r*sin(theta) )
		var tween = b.create_lifecycle_tween()
		tween.tween_property(b, "global_position", pos, 3).from(self.global_position).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func spawn():
	spawn_rose_bullet()
