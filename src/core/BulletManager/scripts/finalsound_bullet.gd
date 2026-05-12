extends Bullet

func bullet_on(pos:Vector2):
	super(pos)
	rotation -= PI/2

func _physics_process(delta: float) -> void:
	super(delta)
	rotation -= PI/2
