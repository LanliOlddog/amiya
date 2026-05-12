extends Node2D

func _physics_process(delta: float) -> void:
	if GameManager.player_launcher_level != 3:
		print(GameManager.player_launcher_level)
		self.queue_free()
