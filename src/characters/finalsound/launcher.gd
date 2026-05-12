extends Node

#@onready var test: Node2D = $test


func attack() -> void:
	var p = get_node("trace")
	p._one_shot()
