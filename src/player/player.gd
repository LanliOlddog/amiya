extends CharacterBody2D

@export var low_speed = 400
@export var default_speed = 1000
@export var respawn_delay: float = 0.8
@export var invincible_time: float = 3.0
@export var respawn_bottom_margin: float = 140.0
@export var game_area_width_ratio: float = 0.68
@export var deathbomb_window: float = 0.18

@onready var launcher: Node2D = $Launcher
@onready var bomb: Node = $Bomb
@onready var collision_shape: CollisionShape2D = $HitPoint/CollisionShape2D
@onready var hit_point: Area2D = $HitPoint

var speed = default_speed
var is_dead := false
var is_invincible := false
var is_hit_pending := false
var _hit_sequence_id := 0

signal player_hit()
signal player_dead()
signal player_respawned()
signal invincible_started(duration: float)
signal invincible_finished()
signal player_hit_pending(duration: float)
signal bomb_requested()
signal deathbomb_used()

func _ready() -> void:
	add_to_group("player")
	hit_point.add_to_group("player")
	hit_point.add_to_group("plyer")
	hit_point.area_entered.connect(_on_hit_point_area_entered)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if Input.is_action_just_pressed("bomb"):
		try_use_bomb(is_hit_pending)
	move(delta)
	shoot()
	
func move(delta: float) -> void:
	if Input.is_action_pressed("concentrate"):
		speed = low_speed
		
	else:
		speed = default_speed
	velocity.x = Input.get_axis("ui_left","ui_right") * speed * delta * 100
	velocity.y = Input.get_axis("ui_up","ui_down") * speed * delta * 1.2 * 100
	move_and_slide()
	
func shoot():
	var is_pressing_shoot = Input.is_action_pressed("shoot")
	launcher.update_firing(is_pressing_shoot)


func _on_hit_point_area_entered(hit_object) -> void:
	if hit_object.is_in_group("enemybullets") or hit_object.is_in_group("enemys") or hit_object is Enemy or hit_object is Boss:
		_hurt()


func _hurt() -> bool:
	if is_dead or is_invincible or is_hit_pending:
		return false

	player_hit.emit()
	start_hit_pending()
	return true


func start_hit_pending() -> void:
	is_hit_pending = true
	_hit_sequence_id += 1
	var current_sequence := _hit_sequence_id
	set_hit_detection_enabled(false)
	player_hit_pending.emit(deathbomb_window)

	await get_tree().create_timer(deathbomb_window).timeout
	if is_hit_pending and current_sequence == _hit_sequence_id:
		is_hit_pending = false
		die()


func try_use_bomb(is_deathbomb: bool = false) -> bool:
	bomb_requested.emit()
	if not bomb.activate(is_deathbomb):
		return false

	BulletManager.clear_enemy_bullets()
	if is_deathbomb:
		cancel_pending_hit()
		deathbomb_used.emit()
	return true


func cancel_pending_hit() -> void:
	if not is_hit_pending:
		return
	is_hit_pending = false
	_hit_sequence_id += 1
	set_hit_detection_enabled(true)


func die() -> void:
	is_hit_pending = false
	is_dead = true
	player_dead.emit()
	launcher.update_firing(false)
	set_hit_detection_enabled(false)
	visible = false

	UIManager.lives = max(0, UIManager.lives - 1)
	UIManager.refresh_status_panel()
	BulletManager.clear_enemy_bullets()
	if UIManager.lives <= 0:
		GameManager.game_over()
		return

	await get_tree().create_timer(respawn_delay).timeout
	respawn()


func respawn() -> void:
	global_position = get_respawn_position()
	visible = true
	is_dead = false
	player_respawned.emit()
	await start_invincible(invincible_time)


func start_invincible(duration: float) -> void:
	is_invincible = true
	set_hit_detection_enabled(false)
	invincible_started.emit(duration)
	await get_tree().create_timer(duration).timeout
	is_invincible = false
	set_hit_detection_enabled(true)
	invincible_finished.emit()


func set_hit_detection_enabled(enabled: bool) -> void:
	if collision_shape:
		collision_shape.set_deferred("disabled", not enabled)
	if hit_point:
		hit_point.set_deferred("monitoring", enabled)
		hit_point.set_deferred("monitorable", enabled)


func get_respawn_position() -> Vector2:
	var viewport_size := get_viewport_rect().size
	var game_area_width := viewport_size.x * get_game_area_width_ratio()
	return Vector2(game_area_width * 0.5, viewport_size.y - respawn_bottom_margin)


func get_game_area_width_ratio() -> float:
	var right_panel := UIManager.get_node_or_null("RightPanel") as Control
	if right_panel:
		return right_panel.anchor_left
	return game_area_width_ratio


func reset_for_restart():
	is_dead = false
	is_invincible = false
	is_hit_pending = false
	_hit_sequence_id += 1
	visible = true
	global_position = get_respawn_position()
	set_hit_detection_enabled(true)
	launcher.update_firing(false)
