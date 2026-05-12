extends Bullet
class_name EnemyBullet

func bullet_on(pos:Vector2):
	super(pos)
	AudioManager.play_sound("amiya_shoot",0.1)

	
