extends Pattern

@export_group("Fan Sweep")
@export_range(1, 64) var ways: int = 9
@export_range(0.0, 180.0) var fan_deg: float = 100.0
@export_range(-360.0, 360.0) var sweep_speed_deg: float = 120.0
@export var aim_at_player: bool = false

@export_group("Bullet")
@export var bullet_speed: float = 320.0
@export var bullet_final_speed: float = 320.0
@export var bullet_acceleration: float = 0.0

var sweep_angle: float = 0.0


func _physics_process(delta: float) -> void:
	sweep_angle += deg_to_rad(sweep_speed_deg) * delta
	super._physics_process(delta)


func spawn():
	if pool.is_empty():
		return

	var base_direction := Vector2.DOWN
	if aim_at_player and is_instance_valid(GameManager.player):
		base_direction = (GameManager.player.global_position - global_position).normalized()
		if base_direction == Vector2.ZERO:
			base_direction = Vector2.DOWN

	var base_angle := base_direction.angle() + PI / 2.0 + sweep_angle
	if ways <= 1:
		spawn_bullet(base_angle)
		return

	var fan := deg_to_rad(fan_deg)
	var start := -fan / 2.0
	var step := fan / float(ways - 1)
	for i in range(ways):
		spawn_bullet(base_angle + start + step * i)


func pattern_off():
	super.pattern_off()
	sweep_angle = 0.0


func spawn_bullet(angle: float):
	if pool.is_empty():
		return
	var bullet = pool.pop_back()
	bullet.direction = Vector2.DOWN.rotated(angle)
	bullet.init_speed = bullet_speed
	bullet.final_speed = bullet_final_speed
	bullet.acceleration = bullet_acceleration
	bullet.bullet_on(global_position)
