extends Node2D

@onready var trans: AnimationPlayer = $trans

func _on_state_revive_revive() -> void:
	trans.play("trans_state")
