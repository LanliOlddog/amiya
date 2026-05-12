extends Node2D
class_name  Enemy

# --- 核心数值 ---
@onready var max_hp = 2000
var current_hp:float

@onready var hp_bar: TextureProgressBar = $canvas/HPBar
@onready var player = GameManager.player

# --- 掉落物配置 (可选) ---
@export var drop_power_items:int = 1
@export var drop_score_items:int = 1

#信号
signal _get_hurt(damage:float)
signal dead

func _ready() -> void:
	current_hp = max_hp

#受伤
func get_hurt(damage:float):
	current_hp -= damage
	_get_hurt.emit(damage)
	if current_hp <= 0:
		die()

#死亡
func die():
	dead.emit()
	var tween_die = create_tween()
	tween_die.tween_property(self,"modulate",Color(0.0, 0.0, 0.0, 0.0),0.5).from(Color(1.0, 1.0, 1.0, 1.0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_die.finished.connect(
		func():
			drop_items()
			queue_free()
			)

func hp_shower():
	hp_bar.value = current_hp / max_hp

#爆金币
func drop_items():
	DropManager.spawn_drops_from_node(self, drop_power_items, drop_score_items)
