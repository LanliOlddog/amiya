extends Pattern
class_name SpiralPattern

##发射的条数
@export var ways:int = 2
##波与粒的境界（）
@export var anti:bool = false
##控制旋转速度
@export var spin_speed:float = 60.0

var spiral_angle:float = 0.0

func _physics_process(delta: float) -> void:
	set_angle(delta)
	super._physics_process(delta)
	
	
func set_angle(delta):
	if not anti:
		spiral_angle += deg_to_rad(spin_speed * delta)
	else:
		var theta = timer * PI/4
		spiral_angle = deg_to_rad(spin_speed * sin(theta)) 
		
func spawn():
	for i in range(ways):
		var b = pool.pop_back()
		b.init_speed = 300
		b.final_speed = 150.0
		b.acceleration= -300
		var angle = spiral_angle + i * TAU/ways
		b.direction = Vector2.DOWN.rotated(angle)
		b.bullet_on(self.global_position)
		

		
