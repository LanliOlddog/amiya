extends Node2D

@export var fire_rate:float = 0.05
@export var bullet_speed:float = 1200
var shoot_timer :float = 0.0

@onready var pool = BulletManager.bullet_pools["player_normal"]
@onready var wingmans = preload("res://src/characters/wingmans/wingmans.tscn")

var has_wingmans:bool = false
var level:int = 1


func _ready() -> void:
	DebugManager.register_player_launcher(self)
	tree_exiting.connect(_on_tree_exiting)


func _physics_process(delta: float) -> void:
	concentrate()
	shoot_time(delta)
		
func shoot_time(delta):
	if shoot_timer > 0:
		shoot_timer -= delta
		

func update_firing(is_shooting: bool):
	if is_shooting and shoot_timer <= 0:
		fire()
		shoot_timer = fire_rate
		
func fire():
	match level:
		1:
			set_bullet_level_1(self.global_position)
		2:
			set_bullet_level_2(self.global_position)
		3:
			set_bullet_level_3(self.global_position)

func concentrate():
	if Input.is_action_pressed("concentrate"):
		fan = PI/36
	if Input.is_action_just_released("concentrate"):
		fan = PI/6
		
	
func set_bullet_level_1(pos):
	var b = pool.pop_back()
	b.direction = Vector2.UP
	b.init_speed = bullet_speed
	b.final_speed = bullet_speed
	b.bullet_on(pos)

@onready var fan = PI/6
func set_bullet_level_2(pos):
	var ways:int = 5
	var step = fan/(ways-1)
	var start_angle = -fan/2
	for i in range(ways):
		var b = pool.pop_back()
		b.direction = Vector2.UP.rotated(start_angle)
		b.init_speed = bullet_speed
		b.final_speed = bullet_speed
		b.bullet_on(pos)
		start_angle += step

func set_bullet_level_3(pos):
	set_bullet_level_2(pos)
	

func add_wingmans():
	if not has_wingmans:
		var game = GameManager.game
		var w = wingmans.instantiate()
		w.name = "wingmans"
		game.add_child(w)
		has_wingmans = true

func delete_wingmans():
	if get_tree().root.has_node("Game/wingmans"):
		var w = get_tree().root.get_node("Game/wingmans")
		w.queue_free()
		has_wingmans = false
	
func _on_option_button_item_selected(index: int) -> void:
	DebugManager.select_player_level(index)


func debug_select_level(index: int):
	level = index + 1
	if index == 2:
		add_wingmans()
	if index != 2:
		delete_wingmans()


func _on_tree_exiting():
	DebugManager.unregister_player_launcher(self)
