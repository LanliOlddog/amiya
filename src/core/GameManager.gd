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

func _ready() -> void:
	Engine.physics_ticks_per_second = 120.0
	player = get_tree().root.get_node("Game/Player")
	game  = get_tree().root.get_node("Game")
	player_launcher_level = player.get_node("Launcher").level

func _physics_process(delta: float) -> void:
	update_level()
	
func update_level():
	player_launcher_level = player.get_node("Launcher").level
	
