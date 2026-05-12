extends Node2D
class_name CombinePattern

@export_group("组合弹幕")
@export var patterns:Array[Pattern] = []


func pattern_on():
	for p in patterns:
		p.pattern_on()

func pattern_off():
	for p in patterns:
		p.pattern_off()
