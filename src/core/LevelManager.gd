extends Node

signal progress_reset

@export var default_progress: float = 0.0
@export var current_progress: float = 0.0


func reset_progress():
	current_progress = default_progress
	progress_reset.emit()
