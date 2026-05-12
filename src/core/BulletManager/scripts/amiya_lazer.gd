extends Bullet
class_name Lazer

@onready var warnning: Sprite2D = $warnning
@onready var shooting: Sprite2D = $shooting
@onready var hurtbox: CollisionShape2D = $hurtbox

@onready var warnning_sound: AudioStreamPlayer = $warnningSound
@onready var lazer_shooting_sound: AudioStreamPlayer = $LazerShooting

var life_time:float = 4.0
var tween_spawn
var tween_fire

func bullet_on(pos:Vector2):
	super.bullet_on(pos)
	hurtbox.disabled = false
	anime()

func anime():
	tween_spawn =  warnning.create_tween()
	warnning_sound.play()
	tween_spawn.tween_property(warnning, "modulate:a", 0.8, 0.3).from(0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_spawn.tween_property(warnning, "modulate:a", 0.81, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_spawn.tween_property(warnning, "modulate:a", 0.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_spawn.finished.connect(fire)
	
func _physics_process(delta: float) -> void:
	life_time -= delta
	die()
	
func fire():
	tween_fire = shooting.create_tween()
	lazer_shooting_sound.play()
	tween_fire.tween_property(shooting,"scale",Vector2(0.4,303), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_fire.tween_property(hurtbox,"scale",Vector2(1,7), 0.1).from(Vector2(0,7)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_fire.tween_property(hurtbox,"scale",Vector2(0,0), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_fire.tween_property(shooting,"scale",Vector2(0,303), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await  tween_fire.finished
	hurtbox.disabled = true
	
func die():
	if life_time < 0.0:
		BulletManager.recycle(self) 
		life_time = 3.0 
