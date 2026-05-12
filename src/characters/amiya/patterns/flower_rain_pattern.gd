extends Pattern

@export_group("Flower Rain")
@export var drop_count: int = 7
@export_range(0.0, 500.0) var spread_x: float = 340.0
@export_range(-180.0, 180.0) var center_angle_deg: float = 0.0
@export_range(0.0, 120.0) var random_angle_deg: float = 28.0

@export_group("Bullet")
@export var min_speed: float = 120.0
@export var max_speed: float = 220.0
@export var final_speed: float = 260.0
@export var acceleration: float = 80.0


func spawn():
	for i in range(drop_count):
		if pool.is_empty():
			return
		var bullet = pool.pop_back()
		var offset_x := randf_range(-spread_x, spread_x)
		var pos := global_position + Vector2(offset_x, 0.0)
		var angle := deg_to_rad(center_angle_deg + randf_range(-random_angle_deg, random_angle_deg))
		bullet.direction = Vector2.DOWN.rotated(angle)
		bullet.init_speed = randf_range(min_speed, max_speed)
		bullet.final_speed = final_speed
		bullet.acceleration = acceleration
		bullet.bullet_on(pos)
