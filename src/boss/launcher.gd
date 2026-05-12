extends Node2D
class_name BossLauncher

##导入弹幕节点
@export var patterns:Array[Node2D] = []
@export var FSM:BossStateMachine
@onready var sprite: AnimatedSprite2D = $"../canvas/sprite"


var pattern_to_use

func _ready() -> void:
	if not FSM and has_node("../FSM"):
		FSM = get_node("../FSM")
	if FSM:
		FSM.state_change.connect(attack)
	DebugManager.register_boss_launcher(self)
	tree_exiting.connect(_on_tree_exiting)
	#FSM.attack_over.connect(attacked)
	
#func on_attack():
	#pattern_to_use = patterns[0]
	##pattern_to_use = patterns.pick_random()
	#await get_tree().create_timer(0.66).timeout
	#pattern_to_use.pattern_on()
#
#func attacked():
	#pattern_to_use.pattern_off()
var i = 0
func attack(from:BossState,to:BossState):
	if to.state_name == "attack":
		await get_tree().create_timer(0.66).timeout
		if FSM.current_state == to:
			start_pattern(i)
	if from.state_name == "attack":
		stop_current_pattern()


func _on_choseskill_item_selected(index: int) -> void:
	DebugManager.select_boss_pattern(index)


func debug_select_pattern(index: int):
	if patterns.is_empty():
		return
	i = wrapi(index, 0, patterns.size())
	if FSM and FSM.current_state.state_name == "nonspell":
		start_pattern(i)

func start_pattern(index: int = -1):
	if patterns.is_empty():
		return
	stop_current_pattern()
	if index >= 0:
		i = wrapi(index, 0, patterns.size())
	pattern_to_use = patterns[i]
	if pattern_to_use and pattern_to_use.has_method("pattern_on"):
		pattern_to_use.pattern_on()

func play_selected_pattern():
	start_pattern(i)

func play_next_pattern():
	if patterns.is_empty():
		return
	i = wrapi(i + 1, 0, patterns.size())
	start_pattern(i)

func stop_current_pattern():
	if pattern_to_use and pattern_to_use.has_method("pattern_off"):
		pattern_to_use.pattern_off()
	pattern_to_use = null


func _on_tree_exiting():
	DebugManager.unregister_boss_launcher(self)
