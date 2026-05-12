extends Pattern

var dirs :Array= [
	Vector2(1,1),
	Vector2(1,-1),
	Vector2(-1,1),
	Vector2(-1,-1),	
]


func spawn_rolling():
	for dir in dirs:
		var pos = self.global_position + dir * 500
		var b = pool.pop_back()
		b.init_speed = 200
		b.final_speed = 10000
		b.acceleration = 100
		b.bullet_on(pos)
	
func spawn():
	spawn_rolling()
	
