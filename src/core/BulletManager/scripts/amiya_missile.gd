extends Bullet

@onready var bullet: Sprite2D = $warnning
@onready var bomb: Area2D = $bomb
@onready var warnning: Sprite2D = $warnning
@onready var lazer_shooting: AudioStreamPlayer = $LazerShooting

var life_time:float = 5.0
var tween_spawn


func bullet_on(pos:Vector2):
	super.bullet_on(pos)
	anime()
	print(direction.angle())
	
func anime():
	tween_spawn = bullet.create_tween()
	lazer_shooting.play()
	tween_spawn.set_loops(3)
	tween_spawn.tween_property(warnning, "modulate:a", 0.5, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_spawn.tween_property(warnning, "modulate:a", 0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_spawn.finished.connect(fire)	
	
func _physics_process(delta: float) -> void:
	life_time -= delta
	die()
	
func fire():
	var tween_bomb = bomb.create_tween()
	tween_bomb.tween_property(bomb, "global_position",Vector2(self.global_position.x,10), 0.5).from(Vector2(self.global_position.x,-100)).set_trans(Tween.TRANS_SINE)
	tween_bomb.tween_property(bomb, "global_position",Vector2(self.global_position.x,1999), 2).set_trans(Tween.TRANS_EXPO)
	print("manbo")
	
func die():
	if life_time < 0.0:
		BulletManager.recycle(self)
		#life_time = 3.0 
		
