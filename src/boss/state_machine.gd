extends Node
class_name  BossStateMachine


@onready var current_state:= states[0]
@onready var next_state: Node = states[0]
@onready var state_time:float = 0.0

@export var auto_change:bool = true
@export var states:Array[BossState] = []

signal state_change(from:Node,to:Node)

func _ready() -> void:
	if current_state:
		current_state.enter()
	DebugManager.register_boss_state_machine(self)
	tree_exiting.connect(_on_tree_exiting)

func _physics_process(delta: float) -> void:
	state_time += delta
	set_state()
	if auto_change:
		current_state.update()


func debug_select_state(index: int):
	if states.is_empty():
		return
	auto_change = false
	next_state = states[wrapi(index, 0, states.size())]


func set_state() -> void:
	if current_state != next_state:
		print("from: %s to: %s" % [current_state.name, next_state.name])
		current_state.exit()
		state_change.emit(current_state,next_state)
		current_state = next_state
		state_time = 0.0
		current_state.enter()


func _on_amiya_boss_dead() -> void:
	if current_state.state_name in ["nonspell","move","idle","attack"]:
		next_state = states[3]
	elif current_state.state_name == "spellcards":
		var spellcard_launcher: SpellcardLauncher = $"../SpellcardLauncher"
		if spellcard_launcher and spellcard_launcher.advance_after_spell_break():
			return
		next_state = states[0]


func _on_tree_exiting():
	DebugManager.unregister_boss_state_machine(self)
