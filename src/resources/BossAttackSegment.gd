extends Resource
class_name BossAttackSegment

@export_group("弹幕")
@export var pattern_index: int = 0

@export_group("持续时间")
@export var duration_min: float = 2.0
@export var duration_max: float = 4.0

@export_group("移动策略")
@export var move_before_attack: bool = true
@export var move_during_attack: bool = false
@export var move_interval: float = 2.0
@export var move_time: float = 1.0


func get_duration() -> float:
	var min_time = min(duration_min, duration_max)
	var max_time = max(duration_min, duration_max)
	return randf_range(min_time, max_time)
