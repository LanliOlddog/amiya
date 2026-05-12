extends Pattern

@onready var enemy: Boss = $"../.."
@export_group("子弹设置")
@export var init_speed := 300.0
@export var final_speed := 150.0
@export var line_count:int = 3
@export var bullet_count_per_line:int = 2
@export_range(-360.0,360.0) var fan_angle:float = 60.0
@export var random_pattern:bool = false
@export var trace_mouse:bool = false


var mouse_pos



func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	mouse_pos = get_viewport().get_mouse_position()

	
func spawn_trace():
	if random_pattern:
		line_count = randi_range(3,6)
		bullet_count_per_line = randi_range(3,5)
		fan_angle = randf_range(45.0,80.0)
	#await get_tree().create_timer(1.05).timeout
	var dir
	if trace_mouse:
		dir = (mouse_pos - enemy.global_position)
	else:
		
	#voice.play()
		dir = (enemy.player.global_position - enemy.global_position)
	dir = dir.normalized()
	var start_angle = -deg_to_rad(fan_angle) / 2
	var step = deg_to_rad(fan_angle) / max(1, line_count - 1)
	for i in range(line_count):
		var bullet_dir = dir.rotated(start_angle + step * i) 
		for j in range(bullet_count_per_line):
			var index = bullet_count_per_line - j -1
			var b = pool.pop_back()
			b.init_speed = init_speed + index * 100
			b.final_speed = final_speed + index * 20
			b.accel_time = 0.1
			b.direction = bullet_dir
			b.bullet_on(enemy.global_position)
	
func spawn():
	spawn_trace()
