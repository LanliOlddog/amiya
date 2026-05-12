extends Node
class_name BossState

@export var state_name:String
@onready var amiya: Boss = $"../.."
@onready var sprite: AnimatedSprite2D = $"../../canvas/sprite"
@onready var FSM: BossStateMachine = $".."


func enter():
	print("进入状态 %s" %name)

	in_state()
	
func exit():
	print("退出状态状态 %s" %name)
	out_state()

func update():
	update_state()

##虚函数
func in_state():
	pass
	
func out_state():
	pass

func update_state():
	pass
