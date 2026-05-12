extends Pattern

@export_group("Moon Wreath")
@export_range(1, 64) var ring_ways: int = 12
@export var ring_speed: float = 260.0
@export var ring_final_speed: float = 140.0
@export var ring_acceleration: float = -180.0
@export_range(-360.0, 360.0) var rotate_step_deg: float = 11.0

@export_group("Burst")
@export var burst_every: int = 5
@export var burst_ways: int = 3
@export var burst_speed: float = 520.0
@export var burst_final_speed: float = 360.0
@export var burst_acceleration: float = -220.0
@export_range(0.0, 180.0) var burst_fan_deg: float = 24.0
@export var aim_at_player: bool = true

var base_angle: float = 0.0
var round_count: int = 0


func spawn():
	if pool.is_empty():
		return

	spawn_ring()
	round_count += 1
	base_angle += deg_to_rad(rotate_step_deg)

	if burst_every > 0 and round_count % burst_every == 0:
		spawn_burst()


func pattern_off():
	super.pattern_off()
	base_angle = 0.0
	round_count = 0


func spawn_ring():
	var step := TAU / float(max(ring_ways, 1))
	for i in range(ring_ways):
		if pool.is_empty():
			return
		var bullet = pool.pop_back()
		bullet.direction = Vector2.DOWN.rotated(base_angle + step * i)
		bullet.init_speed = ring_speed
		bullet.final_speed = ring_final_speed
		bullet.acceleration = ring_acceleration
		bullet.bullet_on(global_position)


func spawn_burst():
	var target_direction := Vector2.DOWN
	if aim_at_player and is_instance_valid(GameManager.player):
		target_direction = (GameManager.player.global_position - global_position).normalized()
		if target_direction == Vector2.ZERO:
			target_direction = Vector2.DOWN

	if burst_ways <= 1:
		spawn_burst_bullet(target_direction)
		return

	var fan := deg_to_rad(burst_fan_deg)
	var start_angle := -fan / 2.0
	var step := fan / float(burst_ways - 1)

	for i in range(burst_ways):
		var direction = target_direction.rotated(start_angle + step * i)
		spawn_burst_bullet(direction)


func spawn_burst_bullet(direction: Vector2):
	if pool.is_empty():
		return
	var bullet = pool.pop_back()
	bullet.direction = direction
	bullet.init_speed = burst_speed
	bullet.final_speed = burst_final_speed
	bullet.acceleration = burst_acceleration
	bullet.bullet_on(global_position)
