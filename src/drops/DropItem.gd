extends Area2D
class_name DropItem

## 掉落物类型。当前支持 "score" 和 "power"，收集时由 DropManager 根据类型发放奖励。
@export var drop_type: StringName = &"score"
## 奖励数值。score 会增加分数，power 会增加 Power 数值。
@export var value: int = 1
## 未被吸附时的自然下落速度。
@export var fall_speed: float = 180.0
## 玩家进入该半径后，掉落物开始朝玩家吸附移动。
@export var attract_radius: float = 180.0
## 吸附时朝玩家移动的目标速度。
@export var attract_speed: float = 520.0
## 掉落物移动速度上限，防止吸附移动过快。
@export var max_speed: float = 900.0
## 存活时间。0 表示不按时间销毁，只在拾取或出屏后清理。
@export var life_time: float = 0.0
## 出屏清理边距。掉落物离开视口后再超过该距离才释放。
@export var offscreen_cleanup_margin: float = 320.0

var _age: float = 0.0
var _collected := false
var _be_carried := false
var _velocity := Vector2.ZERO
var _player: Node2D


func _ready() -> void:
	add_to_group("drops")
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_age += delta
	if not _be_carried and life_time > 0.0 and _age >= life_time:
		DropManager.despawn_drop(self)
		return

	var target := _get_player()
	if is_instance_valid(target) and not _be_carried and global_position.distance_to(target.global_position) <= attract_radius:
		_be_carried = true

	if _be_carried and is_instance_valid(target):
		var direction := global_position.direction_to(target.global_position)
		_velocity = _velocity.move_toward(direction * attract_speed, max_speed * delta)
		_velocity = _velocity.limit_length(max_speed)
	else:
		_velocity = Vector2.DOWN * fall_speed

	global_position += _velocity * delta

	if not _be_carried and _is_outside_viewport():
		DropManager.despawn_drop(self)


func _on_body_entered(body: Node2D) -> void:
	if _collected:
		return
	if body.is_in_group("player") or body == _get_player():
		_collected = true
		DropManager.collect_drop(self)


func _get_player() -> Node2D:
	if is_instance_valid(_player):
		return _player

	var game_manager := get_node_or_null("/root/GameManager")
	if game_manager:
		var game_manager_player := game_manager.get("player") as Node2D
		if is_instance_valid(game_manager_player):
			_player = game_manager_player
			return _player

	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty() and players[0] is Node2D:
		_player = players[0]
		return _player

	return null


func _is_outside_viewport() -> bool:
	var bounds := Rect2(Vector2.ZERO, get_viewport_rect().size).grow(offscreen_cleanup_margin)
	return not bounds.has_point(global_position)
