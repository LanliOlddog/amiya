extends Pattern

@export var lazer_count:int = 18
@onready var amiya: Boss = $"../.."
var dev_angle = TAU / lazer_count

func _ready() -> void:
	super._ready()
	for i in range(lazer_count):
		time_line.append(i*0.1)
		
func spawn():
	var b = pool.pop_back()
	b.direction = Vector2.DOWN.rotated(timer * 10 * dev_angle)
	var p = amiya.player
	b.bullet_on(p.global_position)
