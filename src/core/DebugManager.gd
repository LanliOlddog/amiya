extends Node

signal boss_registered(boss: Boss)
signal boss_state_machine_registered(fsm: BossStateMachine)
signal boss_launcher_registered(launcher: BossLauncher)
signal boss_pattern_selected(index: int)
signal boss_state_selected(index: int)
signal boss_damage_requested(amount: float)
signal bgm_selected(index: int, stream: AudioStream)
signal spellcard_presentation_requested(spellcard: Spellcard)
signal player_level_selected(index: int)

var boss: Boss
var boss_state_machine: BossStateMachine
var boss_launcher: BossLauncher
var player_launcher: Node


func register_boss(target: Boss):
	boss = target
	boss_registered.emit(target)


func unregister_boss(target: Boss):
	if boss == target:
		boss = null


func register_boss_state_machine(target: BossStateMachine):
	boss_state_machine = target
	boss_state_machine_registered.emit(target)


func unregister_boss_state_machine(target: BossStateMachine):
	if boss_state_machine == target:
		boss_state_machine = null


func register_boss_launcher(target: BossLauncher):
	boss_launcher = target
	boss_launcher_registered.emit(target)


func unregister_boss_launcher(target: BossLauncher):
	if boss_launcher == target:
		boss_launcher = null


func register_player_launcher(target: Node):
	player_launcher = target


func unregister_player_launcher(target: Node):
	if player_launcher == target:
		player_launcher = null


func select_boss_state(index: int):
	boss_state_selected.emit(index)
	if boss_state_machine and boss_state_machine.has_method("debug_select_state"):
		boss_state_machine.debug_select_state(index)


func select_boss_pattern(index: int):
	boss_pattern_selected.emit(index)
	if boss_launcher and boss_launcher.has_method("debug_select_pattern"):
		boss_launcher.debug_select_pattern(index)


func damage_boss(amount: float = 10.0):
	boss_damage_requested.emit(amount)
	if boss:
		boss.take_damage(amount)


func select_bgm(index: int, stream: AudioStream):
	bgm_selected.emit(index, stream)
	AudioManager.set_BGM(stream)


func select_player_level(index: int):
	player_level_selected.emit(index)
	if player_launcher and player_launcher.has_method("debug_select_level"):
		player_launcher.debug_select_level(index)


func play_spellcard_presentation():
	var spellcard := get_debug_spellcard()
	if not spellcard:
		return
	spellcard_presentation_requested.emit(spellcard)
	PresentationManager.show_spellcard_announcement(spellcard)


func get_debug_spellcard() -> Spellcard:
	if not boss or not boss.spellcard_launcher:
		return null
	var spellcards := boss.spellcard_launcher.spellcards
	if spellcards.is_empty():
		return null
	var current_index: int = boss.spellcard_launcher.current_spellcard_index
	if current_index < 0 or current_index >= spellcards.size():
		current_index = 0
	return spellcards[current_index]
