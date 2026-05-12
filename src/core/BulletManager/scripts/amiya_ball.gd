extends Bullet

func bullet_on(pos:Vector2):
	super.bullet_on(pos)
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(0.5,0.5),1.2).from(Vector2.ZERO).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
func rolling(delta):
	self.rotation += delta * deg_to_rad(120.0)
