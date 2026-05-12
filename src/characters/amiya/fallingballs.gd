extends Pattern

func spawn():
	var b = pool.pop_back()
	var rot = randf_range(-1,1) * PI/ 3.5
	var pos = global_position + Vector2( randf_range(-100,100), 30)
	b.direction = Vector2.DOWN.rotated(rot)
	b.init_speed = 100.0
	b.bullet_on(pos)
