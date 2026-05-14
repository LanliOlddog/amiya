extends Area2D
class_name Bullet

@export_group("运动参数")
##子弹初速度
var init_speed:float= 0.0
##子弹最终速度
var final_speed :float= 1000
##加速时间
var acceleration :float = 0
##子弹初始方向
@export var direction := Vector2.DOWN
@export var pool_name:String
var speed :float= 0.0
var is_active:bool = false
var active_tweens: Array[Tween] = []
##击中后是否消失
@export var delete_on_hit:bool= true

var version_shape
var hit_box

func _ready() -> void:	
	bullet_off()
	if has_node("VersionShape"):
		version_shape = get_node("VersionShape")
		version_shape.screen_exited.connect(_on_screen_exited)
	self.area_entered.connect(_on_area_entered)


	
func _physics_process(delta: float) -> void:
	move(delta)
	rolling(delta)
	
##子弹运动
func move(delta):
	if init_speed < final_speed:
		if speed < final_speed:
			speed += acceleration * delta
	elif  init_speed > final_speed:
		if speed > final_speed:
			speed += acceleration * delta
	position += direction * speed * delta
	

func rolling(delta):
	rotation = direction.angle() - PI/2
	
##从对象池激活子弹，设定位置，打开可见，设置进程
func bullet_on(pos:Vector2):
	kill_active_tweens()
	if has_meta(&"player_grazed"):
		remove_meta(&"player_grazed")
	is_active = true
	if BulletManager and BulletManager.has_method("mark_bullet_active"):
		BulletManager.mark_bullet_active(self)
	speed = init_speed
	self.global_position = pos
	self.visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	rotation = direction.angle() - PI/2


##关闭子弹，关闭可见，设定位置到屏幕外，关闭进程
func bullet_off():
	kill_active_tweens()
	is_active = false
	self.visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	position = Vector2(-100.0,-100.0)


func create_lifecycle_tween() -> Tween:
	var tween := create_tween()
	active_tweens.append(tween)
	return tween


func kill_active_tweens():
	for tween in active_tweens:
		if tween and tween.is_valid():
			tween.kill()
	active_tweens.clear()


func reset():
	pass
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("plyer") and delete_on_hit:
		BulletManager.recycle(self)
#
#
#func _on_body_entered(body: Node2D) -> void:
	#if body is CharacterBody2D:
		#body._hurt()
		#BulletManager.recycle(self)

#子弹出屏幕，调用单例中的回收
func _on_screen_exited() -> void:
	if not is_active or not visible:
		return
	await get_tree().physics_frame
	if is_active and visible and version_shape and not version_shape.is_on_screen():
		BulletManager.recycle(self)
	
