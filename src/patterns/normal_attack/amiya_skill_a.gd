extends Node2D
class_name  Skill

var skill_timer: float = 0.0
#var skill_period:float = 3.5
@onready var bullet_manager: Node = $"../../bulletpool"


#在某一时刻触发一次
func met_tick(time:float,delta:float,tick:float) ->bool:
	return time >= tick and time < tick +delta

func _physics_process(delta: float) -> void:
	use_skill(delta)

#按照信号传入的delta执行进程	
func use_skill(delta):
	skill_timer += delta
	for i in range(0,7,2):
		var ticks = i * 1.0 + 0.1
		if met_tick(skill_timer,delta,ticks):
			var target_pos = [Vector2(100,200),Vector2(780,200),Vector2(100,611),Vector2(780,611)]
			for pos in target_pos:
				BulletManager.spawn("amiya_ball",pos)
		
