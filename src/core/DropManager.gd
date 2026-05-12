extends Node

@export_group("生成偏移")
@export var default_drop_spread: Vector2 = Vector2(36.0, 24.0)

const DROP_SCENES := {
	"power": preload("res://src/drops/power_drop.tscn"),
	"score": preload("res://src/drops/score_drop.tscn"),
}


func spawn_drop(type: StringName, drop_position: Vector2, value: int = 1, spread: Vector2 = Vector2.ZERO) -> DropItem:
	var type_key := String(type)
	var drop_scene: PackedScene = DROP_SCENES.get(type_key)
	if drop_scene == null:
		push_warning("Unknown drop type: %s" % type_key)
		return null

	var drop_item := drop_scene.instantiate() as DropItem
	if drop_item == null:
		push_warning("Drop scene is not a DropItem: %s" % type_key)
		return null

	drop_item.drop_type = type
	drop_item.value = value

	var parent := _get_drop_parent()
	parent.add_child(drop_item)
	drop_item.global_position = drop_position + get_random_offset(spread)
	return drop_item


func spawn_drop_from_node(type: StringName, source: Node2D, local_offset: Vector2 = Vector2.ZERO, value: int = 1, spread: Vector2 = Vector2(-1.0, -1.0)) -> DropItem:
	if not is_instance_valid(source):
		return null
	return spawn_drop(type, source.global_position + local_offset, value, spread)


func spawn_drops(drop_position: Vector2, power_count: int, score_count: int, spread: Vector2 = Vector2(-1.0, -1.0)) -> void:
	_spawn_drop_group(&"power", drop_position, power_count, spread)
	_spawn_drop_group(&"score", drop_position, score_count, spread)


func spawn_drops_from_node(source: Node2D, power_count: int, score_count: int, local_offset: Vector2 = Vector2.ZERO, spread: Vector2 = Vector2(-1.0, -1.0)) -> void:
	if not is_instance_valid(source):
		return
	spawn_drops(source.global_position + local_offset, power_count, score_count, spread)


func collect_drop(drop_item: DropItem) -> void:
	if not is_instance_valid(drop_item):
		return

	match String(drop_item.drop_type):
		"score":
			UIManager.add_score(drop_item.value)
		"power":
			UIManager.add_power(drop_item.value)
		_:
			push_warning("Unknown drop type: %s" % String(drop_item.drop_type))

	despawn_drop(drop_item)


func despawn_drop(drop_item: DropItem) -> void:
	if is_instance_valid(drop_item) and not drop_item.is_queued_for_deletion():
		drop_item.queue_free()


func get_random_offset(spread: Vector2) -> Vector2:
	if spread.x < 0.0 or spread.y < 0.0:
		spread = default_drop_spread
	return Vector2(randf_range(-spread.x, spread.x), randf_range(-spread.y, spread.y))


func _spawn_drop_group(type: StringName, origin: Vector2, count: int, spread: Vector2) -> void:
	for i in range(max(0, count)):
		spawn_drop(type, origin, 1, spread)


func _get_drop_parent() -> Node:
	var game := get_tree().root.get_node_or_null("Game")
	if game:
		return game

	if get_tree().current_scene:
		return get_tree().current_scene

	return get_tree().root
