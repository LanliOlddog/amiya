extends BossState

func in_state():
	#var into = amiya.create_tween()
	#into.tween_property(amiya,"position",Vector2(563.0, 300.0),1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	sprite.play("idle")
	

func update_state() ->void:
	if FSM.state_time > 3.0:
		FSM.next_state = FSM.states[1]
