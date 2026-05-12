extends BossState

signal revive

@export var home_position: Vector2 = Vector2(440.0, 270.0)
@export var return_time: float = 1.0

var return_finished: bool = false
var return_tween: Tween

func in_state():
	return_finished = false
	sprite.play("revive")
	revive.emit()
	return_to_home()
	

func update_state():
	if return_finished and not sprite.is_playing():
		FSM.next_state = FSM.states[4]

func out_state():
	if return_tween and return_tween.is_valid():
		return_tween.kill()

func return_to_home():
	if return_tween and return_tween.is_valid():
		return_tween.kill()
	return_tween = create_tween()
	return_tween.finished.connect(func(): return_finished = true)
	return_tween.tween_property(amiya, "position", home_position, return_time)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
