extends Node2D
class_name Pattern

@export var bullet_type :String
@export var time_line:Array[float] = []
@export var is_loop:bool = false
@export var loop_rate:float = 1.0
var loop_timer:float = 0.0
@export var one_shot:bool = false

var time_start:bool = false
##弹幕开始后经过的时间
var timer: float = 0.0
##弹幕用的子弹池
var pool




func _ready() -> void:
	pool = BulletManager.bullet_pools[bullet_type]


#用于按时间触发弹幕
func met_tick(time:float,delta:float,tick:float) ->bool:
	return time >= tick and time < tick +delta



func _physics_process(delta: float) -> void:
	if time_start:
		timer += delta
		loop_timer += delta
		spawn_pattern(delta)


func spawn_pattern(delta):
	##循环弹幕
	if is_loop:
		time_line = []
		if loop_timer > loop_rate:
			loop_timer = 0
			spawn()
	##不循环
	else:
		#只发一次
		if one_shot:
			if met_tick(timer,delta,0.001):
				spawn()
			#有时间线
		for t in time_line:
			if met_tick(timer,delta,t):
				spawn()

##使用弹幕就用这个
func pattern_on():
	time_start = true
	
func pattern_off():
	time_start = false
	timer = 0.0
	loop_timer = 0.0
	print("打完了")
##虚函数，用于继承的弹幕写自己的逻辑
#单次发射
func spawn():
	pass
