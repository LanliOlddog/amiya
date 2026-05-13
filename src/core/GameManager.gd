extends Node
# 游戏状态管理 (分数, 残机, 暂停)

# --- 游戏状态枚举 ---
enum GameState {
	IDLE,       # 主菜单
	PLAYING,    # 游戏中
	PAUSED,     # 暂停
	DIALOGUE,   # 对话中 (子弹冻结但可以按键)
	GAME_OVER,  # 结束
	STAGE_CLEAR # 通关
}

var player
var game
var player_launcher_level
var current_state: GameState = GameState.PLAYING

@export var default_lives: int = 3
@export var default_bombs: int = 3
@export var default_power: float = 0.0
@export var default_player_level: int = 1

func _ready() -> void:
	Engine.physics_ticks_per_second = 120.0
	player = get_tree().root.get_node("Game/Player")
	game  = get_tree().root.get_node("Game")
	player_launcher_level = player.get_node("Launcher").level
	UIManager.restart.connect(restart_game)

func _physics_process(delta: float) -> void:
	update_level()
	
func update_level():
	player_launcher_level = player.get_node("Launcher").level


func game_over():
	if current_state == GameState.GAME_OVER:
		return
	current_state = GameState.GAME_OVER
	BulletManager.clear_enemy_bullets()
	UIManager.show_game_over()


func restart_game():
	current_state = GameState.PLAYING
	UIManager.hide_game_over()
	UIManager.set_player_resources(default_lives, default_bombs, default_power)
	BulletManager.clear_enemy_bullets()
	reset_boss_progress()
	reset_player_progress()
	reset_level_progress()


func reset_boss_progress():
	var spellcard_launcher = DebugManager.boss.spellcard_launcher if DebugManager.boss else null
	if spellcard_launcher:
		spellcard_launcher.stop_current_spellcard()
		spellcard_launcher.reset_spell_sequence()
	if DebugManager.boss:
		DebugManager.boss.set_hp_full()
	if DebugManager.boss_state_machine and DebugManager.boss_state_machine.has_method("reset_phase"):
		DebugManager.boss_state_machine.reset_phase()


func reset_player_progress():
	if not is_instance_valid(player):
		player = get_tree().root.get_node_or_null("Game/Player")
	if player and player.has_method("reset_for_restart"):
		player.reset_for_restart()
	if player:
		player.set_process_input(true)
	var launcher = player.get_node_or_null("Launcher") if player else null
	if launcher and launcher.has_method("reset_firepower"):
		launcher.reset_firepower(default_player_level)
	player_launcher_level = default_player_level


func reset_level_progress():
	var level_manager = game.get_node_or_null("LevelManager") if game else null
	if level_manager and level_manager.has_method("reset_progress"):
		level_manager.reset_progress()
	
