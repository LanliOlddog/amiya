extends Area2D
class_name Boss

@onready var sprite: AnimatedSprite2D = $canvas/sprite
@onready var hp_bar: TextureProgressBar = $UI/HPBar
@onready var spellcard_launcher: SpellcardLauncher = $SpellcardLauncher

@onready var player

# --- Boss血量 ---
@export var max_hp: float = 100.0
@export var current_hp: float

# --- 信号 ---
signal get_hurt(damage: float)
signal boss_dead

func _ready() -> void:
	add_to_group("enemys")
	player = GameManager.player
	current_hp = max_hp
	update_hp_bar()
	DebugManager.register_boss(self)
	tree_exiting.connect(_on_tree_exiting)
	

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("playerbullets"):
		var active_spellcard = get_active_spellcard()
		if active_spellcard and active_spellcard.is_on:
			# 假设子弹有damage属性，如果没有则使用默认值
			var damage = 10.0
			take_damage(damage)
		else:
			# 没有激活符卡，伤害Boss本体
			var damage = 10.0
			#var damage = area.get("damage") if area.has_method("get") else 10.0
			take_damage(damage)
		# 回收子弹
		if area is Bullet:
			BulletManager.recycle(area)
# Boss本体受伤
func take_damage(amount: float = 10.0) -> void:
	if current_hp <= 0:
		return
	current_hp -= amount
	current_hp = max(0.0, current_hp)
	get_hurt.emit(amount)
	update_hp_bar()
	
	if current_hp <= 0:
		BulletManager.clear_enemy_bullets()
		boss_dead.emit()


func _on_tree_exiting():
	DebugManager.unregister_boss(self)

# 更新血条显示
func update_hp_bar() -> void:
	if hp_bar:
		hp_bar.value = (current_hp / max_hp) 

func reset_hp():
	var tween_recover = create_tween()
	tween_recover.tween_method(
		func(new_hp:float):
			current_hp = new_hp
			update_hp_bar(),
	0,
	max_hp,
	3.0
	)

func set_hp_full():
	current_hp = max_hp
	update_hp_bar()
	
	
## Boss死亡
#func die() -> void:
	#boss_dead.emit()
	#print("Boss被击败！")
	## 添加死亡动画/效果
	#var tween_die = create_tween()
	#tween_die.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 1.0)
	#tween_die.tween_callback(queue_free)

# 获取当前激活的符卡
func get_active_spellcard() -> Spellcard:
	if not spellcard_launcher:
		return null
	for spellcard in spellcard_launcher.spellcards:
		if spellcard.is_on:
			return spellcard
	return null
