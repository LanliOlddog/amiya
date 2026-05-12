extends Pattern

@onready var amiya: Boss = $"../../.."

func spawn():
	var b = pool.pop_back()
	var p = amiya.player
	b.bullet_on(p.global_position)
