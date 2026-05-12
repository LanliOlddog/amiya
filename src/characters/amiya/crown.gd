extends Pattern

@export_group("黑冠环绕")
@export_range(1, 64) var ball_count: int = 12
@export var min_radius: float = 90.0
@export var max_radius: float = 160.0
@export var rotation_speed_deg: float = 75.0
@export var breath_period: float = 3.0
@export var start_angle_deg: float = 0.0

@export_group("球体外观")
@export var ball_scale: Vector2 = Vector2(0.9, 0.9)
@export var ball_color: Color = Color.BLACK

@export_group("光晕")
@export var halo_scale_multiplier: float = 2.2
@export_range(0.0, 1.0) var halo_alpha: float = 0.65
@export var halo_color: Color = Color.WHITE

var orbit_bullets: Array[Bullet] = []
var orbit_time: float = 0.0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not time_start:
		return
	orbit_time += delta
	update_orbit()


func spawn():
	clear_orbit_bullets()
	orbit_time = 0.0

	for i in range(ball_count):
		if pool.is_empty():
			return
		var bullet: Bullet = pool.pop_back()
		setup_orbit_bullet(bullet)
		bullet.bullet_on(global_position)
		orbit_bullets.append(bullet)

	update_orbit()


func pattern_off():
	super.pattern_off()
	clear_orbit_bullets()
	orbit_time = 0.0


func update_orbit():
	if orbit_bullets.is_empty():
		return

	var base_angle := deg_to_rad(start_angle_deg) + deg_to_rad(rotation_speed_deg) * orbit_time
	var radius := get_breath_radius()
	var step := TAU / float(max(ball_count, 1))

	for i in range(orbit_bullets.size()):
		var bullet := orbit_bullets[i]
		if not is_instance_valid(bullet):
			continue
		var angle := base_angle + step * i
		bullet.global_position = global_position + Vector2.RIGHT.rotated(angle) * radius


func get_breath_radius() -> float:
	if breath_period <= 0.0:
		return max_radius
	var t := (sin(orbit_time / breath_period * TAU - PI / 2.0) + 1.0) / 2.0
	return lerp(min_radius, max_radius, t)


func setup_orbit_bullet(bullet: Bullet):
	remember_original_look(bullet)
	bullet.init_speed = 0.0
	bullet.final_speed = 0.0
	bullet.acceleration = 0.0
	bullet.direction = Vector2.ZERO
	bullet.scale = ball_scale
	bullet.modulate = Color.WHITE

	var sprite := bullet.get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.modulate = ball_color
		ensure_halo_sprite(bullet, sprite)


func ensure_halo_sprite(bullet: Bullet, source_sprite: Sprite2D):
	var halo := bullet.get_node_or_null("CrownHalo") as Sprite2D
	if not halo:
		halo = Sprite2D.new()
		halo.name = "CrownHalo"
		halo.z_index = source_sprite.z_index - 1
		bullet.add_child(halo)

	halo.texture = source_sprite.texture
	halo.centered = source_sprite.centered
	halo.offset = source_sprite.offset
	halo.scale = source_sprite.scale * halo_scale_multiplier
	halo.modulate = Color(halo_color.r, halo_color.g, halo_color.b, halo_alpha)
	halo.visible = true


func clear_orbit_bullets():
	for bullet in orbit_bullets:
		if is_instance_valid(bullet):
			restore_original_look(bullet)
			BulletManager.recycle(bullet)
	orbit_bullets.clear()


func remember_original_look(bullet: Bullet):
	if not bullet.has_meta("crown_original_scale"):
		bullet.set_meta("crown_original_scale", bullet.scale)

	var sprite := bullet.get_node_or_null("Sprite2D") as Sprite2D
	if sprite and not bullet.has_meta("crown_original_sprite_modulate"):
		bullet.set_meta("crown_original_sprite_modulate", sprite.modulate)


func restore_original_look(bullet: Bullet):
	if bullet.has_meta("crown_original_scale"):
		bullet.scale = bullet.get_meta("crown_original_scale")

	var sprite := bullet.get_node_or_null("Sprite2D") as Sprite2D
	if sprite and bullet.has_meta("crown_original_sprite_modulate"):
		sprite.modulate = bullet.get_meta("crown_original_sprite_modulate")

	var halo := bullet.get_node_or_null("CrownHalo") as Sprite2D
	if halo:
		halo.visible = false
