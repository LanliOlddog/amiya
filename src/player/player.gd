extends CharacterBody2D

@export var low_speed = 400
@export var default_speed = 1000

@onready var launcher: Node2D = $Launcher

var speed = default_speed

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
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
