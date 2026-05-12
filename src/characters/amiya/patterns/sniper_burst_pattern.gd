extends Pattern

@export_group("Sniper Burst")
@export var burst_count: int = 4
@export_range(0.0, 180.0) var arc_deg: float = 36.0
@export var fallback_direction: Vector2 = Vector2.DOWN

@export_group("Bullet")
@export var bullet_speed: float = 700.0
@export var bullet_final_speed: float = 500.0
@export var bullet_acceleration: float = -260.0


func spawn():
	var base_direction := fallback_direction.normalized()
	if is_instance_valid(GameManager.player):
		base_direction = (GameManager.player.global_position - global_position).normalized()
		if base_direction == Vector2.ZERO:
			base_direction = fallback_direction.normalized()

	if burst_count <= 1:
		spawn_bullet(base_direction)
		return

	var fan := deg_to_rad(arc_deg)
	var start := -fan / 2.0
	var step := fan / float(burst_count - 1)
	for i in range(burst_count):
		spawn_bullet(base_direction.rotated(start + step * i))


func spawn_bullet(direction: Vector2):
	if pool.is_empty():
		return
	var bullet = pool.pop_back()
	bullet.direction = direction
	bullet.init_speed = bullet_speed
	bullet.final_speed = bullet_final_speed
	bullet.acceleration = bullet_acceleration
	bullet.bullet_on(global_position)
