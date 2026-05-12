extends Pattern

@onready var amiya: Boss = $"../../.."

func spawn():
	var player = amiya.player
	var pos_random_x = player.global_position.x + randf_range(-20.0,20.0)
	var b = pool.pop_back()
	b.bullet_on(Vector2(pos_random_x,0))
