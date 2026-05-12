extends Node2D
class_name Spellcard

# --- 符卡特有属性 ---
@export var spell_name: String = "符卡名"
##符卡使用弹幕
@export var patterns:Array[Pattern] = []
##符卡血量
@export var max_hp: float = 1000.0
##符卡时间
@export var timeout: float = 60.0
##符卡分数
@export var spell_bonus: int = 100000
##符卡背景图
@export var background_image: Texture2D

##符卡立绘
@export var sprite_texture:Texture2D
# ---状态
var current_hp:float = 0.0
var timer:float = 0.0
var is_on:bool = false

# --- 信号 ---
signal spell_finished(success: bool) # 成功击破或超时
signal health_changed(ratio: float)

func _physics_process(delta: float) -> void:
	if not is_on:
		return
	timer -= delta
	if timer < 0.0:
		_on_timeout()
##受伤
func take_damage(amount: float):
	if not is_on:
		return
	current_hp -= amount
	health_changed.emit(current_hp / max_hp)
	if current_hp <= 0:
		_on_break()
##击破
func _on_break():
	print("符卡击破！Get Bonus!")
	spell_finished.emit(true)
	spellcard_off()
##时间结束
func _on_timeout():
	print("时间到！Failed!")
	spell_finished.emit(false)
	spellcard_off()
##启用符卡		
func spellcard_on():
	is_on = true
	current_hp = max_hp
	timer = timeout
	await PresentationManager.show_spellcard_announcement(self)
	for p in patterns:
		p.pattern_on()
	print("符卡 [%s] 启动！" % spell_name)
##结束符卡
func spellcard_off():
	is_on = false
	# 关闭所有发射器
	for p in patterns:
		p.pattern_off()
	# 清除屏幕子弹 (可选)
	# BulletManager.clear_all()
