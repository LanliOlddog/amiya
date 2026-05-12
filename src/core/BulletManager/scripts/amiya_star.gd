extends Bullet

var timer:float = 0.0
var player

func _ready() -> void:
	super._ready()
	#player = get_tree().root.get_node("main/player")
	

func met_tick(time:float,delta:float,tick:float) ->bool:
	return time >= tick and time < tick +delta
	
func anime():
	var tween =create_tween()
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.25).from(Vector2(0.1,0.1))
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	timer += delta
	self.rotation += deg_to_rad(450*delta)
	if met_tick(timer,delta,2.9):
		var dir:Vector2 = player.global_position - global_position
		direction = dir.normalized()
	if timer > 3.0:
		move(delta)


func _on_body_entered(body: Node2D) -> void:	

	if body is CharacterBody2D:
		body._hurt()
		queue_free()
