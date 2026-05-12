extends Node2D

@export_group("跟随设置")
@export var follow_speed: float = 5.0  # 跟随速度（越大越紧贴，越小滞后越明显）
@export var offset: Vector2 = Vector2.ZERO  # 相对玩家的偏移量（在编辑器中设置）

@export_group("子弹设置")
@export var fire_rate:float = 0.05
@export var bullet_speed:float = 1200
var pool 

var target_position: Vector2
var player: Node2D  # 玩家节点

var current_offset: Vector2 = Vector2.ZERO
var shoot_timer :float = 0.0

func _ready() -> void:
	pool = BulletManager.bullet_pools["wingman_bullet"]
	player = GameManager.player
	current_offset = offset
	if player:
		target_position = player.global_position + current_offset
		global_position = target_position

func shoot_time(delta):
	if shoot_timer > 0:
		shoot_timer -= delta
	
func _physics_process(delta: float) -> void:
	if not player:
		return
	concentrate()
	follow_player(delta)
	shoot_time(delta)
	shoot()

func shoot():
	var is_pressing_shoot = Input.is_action_pressed("shoot")
	if is_pressing_shoot and shoot_timer <= 0:
		fire()
		shoot_timer = fire_rate
		
	
func concentrate():
	if Input.is_action_pressed("concentrate"):
		current_offset = Vector2(0,-80)
	if Input.is_action_just_released("concentrate"):
		current_offset = offset

func follow_player(delta):
	target_position = player.global_position + current_offset
	global_position = global_position.lerp(target_position, 1.0 - exp(-follow_speed * delta))

func fire():
	var b = pool.pop_back()
	b.direction = Vector2.UP
	b.init_speed = bullet_speed
	b.final_speed = bullet_speed
	b.scale = Vector2(0.4,0.5)
	b.modulate = Color(0.835, 0.668, 0.049, 1.0)
	b.bullet_on(self.global_position)
	
