extends Node2D


enum STATES{
	IDLE,
	ATTACK,
	DEAD
}

@onready var launcher: Node2D = $"../Launcher"
@onready var sprite: AnimatedSprite2D = $"../canvas/Sprite"
@onready var enemy: Enemy = $".."

@onready var current_state = STATES.IDLE
@onready var next_state = STATES.IDLE

var rand_time:float
func _ready() -> void:
	var tween_intro = create_tween()
	tween_intro.tween_property(sprite,"modulate",Color(1,1,1,1),1.5).from(Color(0.0, 0.0, 0.0, 0.0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _physics_process(delta: float) -> void:
	change_state()
	update_state()
	state_time += delta
	#trace_mouse()
	
	
#===================
#状态机逻辑区
#===================
var state_time:float = 0.0
func change_state():
	if current_state == next_state:
		return
	on_state_change(current_state,next_state)
	current_state = next_state
	
func on_state_change(from:int,to:int):
	match to:
		STATES.IDLE:
			state_time = 0
			sprite.play("idle")
			#luandong()
		STATES.ATTACK:
			state_time = 0
			sprite.play("attack")
			await get_tree().create_timer(1.03).timeout
			launcher.attack()
		STATES.DEAD:
			state_time = 0
			sprite.play("dead")
			sprite.animation_finished.connect(enemy.die)
				

func update_state():
	if enemy.current_hp < 0:
		next_state =STATES.DEAD
	match current_state:
		STATES.IDLE:
			if state_time > 0.5:
				next_state = STATES.ATTACK
		STATES.ATTACK:
			if not sprite.is_playing():
				next_state = STATES.IDLE
#===================
#小逻辑
#===================

	
	
	
