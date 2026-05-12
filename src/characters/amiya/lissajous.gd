extends Pattern

#李萨如曲线公式 x=Asin(at+δ),y=Bsin(bt)
#a/b 控制形状复杂度
#δ 控制相位差
@export var A:float = 300.0
@export var B:float = 200.0
@export var a:float = 3.0
@export var b:float = 4.0
@export var theta:float = TAU/4
@export var bullet_count:int =720

func spawn_lissajous_bullet():
	for i in range(bullet_count):
		var tween = create_tween()
		var t = deg_to_rad(i * 2)
		var pos = self.global_position + Vector2( A*sin(a*t + theta) , B*sin(b*t) )
		var bl =  pool.pop_back()

		bl.init_speed = randf()*100
		bl.final_speed = randf()*1000 + 500
		bl.acceleration = (randf()*1000)
		var dir = Vector2( A*sin(a*t + theta) , B*sin(b*t) ).normalized()
		bl.direction = dir.rotated(deg_to_rad( randf_range( -30.0,30.0) ))
		bl.bullet_on(pos)
		tween.tween_property(bl, "global_position", pos, 1.5).from(self.global_position).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		

func spawn():
	spawn_lissajous_bullet()
