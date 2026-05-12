extends BossState




func in_state():
	sprite.play("attack")

func update_state():
	if not sprite.is_playing():
		FSM.next_state = FSM.states[1]
