extends Node2D
class_name SpellcardLauncher

##导入弹幕节点
@export var spellcards:Array[Spellcard] = []
@export var FSM:BossStateMachine
@onready var sprite: AnimatedSprite2D = $"../canvas/sprite"
@onready var boss: Boss = $".."


var spellcard_to_use
var current_spellcard_index: int = 0

func _ready() -> void:
	if not FSM and has_node("../FSM"):
		FSM = get_node("../FSM")
	if FSM:
		FSM.state_change.connect(use_spellcard)


func use_spellcard(from:BossState,to:BossState):
	if to.state_name == "spellcards":
		start_current_spellcard()
		
	if from.state_name == "spellcards":
		stop_current_spellcard()

func start_current_spellcard():
	if spellcards.is_empty():
		return
	current_spellcard_index = clampi(current_spellcard_index, 0, spellcards.size() - 1)
	spellcard_to_use = spellcards[current_spellcard_index]
	if boss:
		boss.set_hp_full()
	spellcard_to_use.spellcard_on()

func stop_current_spellcard():
	if spellcard_to_use:
		spellcard_to_use.spellcard_off()

func advance_after_spell_break() -> bool:
	stop_current_spellcard()
	current_spellcard_index += 1
	if current_spellcard_index >= spellcards.size():
		spellcard_to_use = null
		return false
	start_current_spellcard()
	return true

func reset_spell_sequence():
	current_spellcard_index = 0
	spellcard_to_use = null
