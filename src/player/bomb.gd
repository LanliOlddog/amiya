extends Node

signal started(is_deathbomb: bool)


func activate(is_deathbomb: bool = false) -> bool:
	if UIManager.bombs <= 0:
		print("没有可用炸弹")
		return false

	UIManager.bombs -= 1
	UIManager.refresh_status_panel()
	print("释放炸弹")
	started.emit(is_deathbomb)
	return true
