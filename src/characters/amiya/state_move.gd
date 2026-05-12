extends BossState

@export_group("非符移动区域")
@export var move_area_min: Vector2 = Vector2(320.0, 180.0)
@export var move_area_max: Vector2 = Vector2(560.0, 360.0)
@export var min_move_distance: float = 80.0

@export_group("非符节奏")
@export var first_attack_delay: float = 0.5
@export var default_duration_min: float = 3.0
@export var default_duration_max: float = 4.5
@export var default_move_time: float = 1.1
@export var default_move_interval: float = 2.8
@export var attack_segments: Array[BossAttackSegment] = []

@onready var launcher: BossLauncher = $"../../Launcher"

var last_segment_index: int = -1
var current_segment: BossAttackSegment
var pattern_active: bool = false
var waiting_for_pre_move: bool = false
var next_segment_time: float = 0.0
var segment_end_time: float = 0.0
var next_move_time: float = 0.0
var move_tween: Tween


func in_state():
	sprite.play("idle")
	last_segment_index = -1
	current_segment = null
	pattern_active = false
	waiting_for_pre_move = false
	next_segment_time = first_attack_delay
	segment_end_time = 0.0
	next_move_time = 0.0


func out_state():
	stop_move_tween()
	if launcher:
		launcher.stop_current_pattern()


func update_state():
	if waiting_for_pre_move:
		if FSM.state_time >= next_segment_time:
			begin_segment_pattern()
		return

	if not pattern_active:
		if FSM.state_time >= next_segment_time:
			prepare_segment()
		return

	if current_segment and current_segment.move_during_attack and FSM.state_time >= next_move_time:
		move_to_new_position(current_segment.move_time)
		next_move_time += max(current_segment.move_interval, 0.1)

	if FSM.state_time >= segment_end_time:
		finish_segment()
		next_segment_time = FSM.state_time
		prepare_segment()


func prepare_segment():
	current_segment = get_current_segment()

	if current_segment.move_before_attack:
		move_to_new_position(current_segment.move_time)
		waiting_for_pre_move = true
		next_segment_time = FSM.state_time + current_segment.move_time
	else:
		begin_segment_pattern()


func begin_segment_pattern():
	waiting_for_pre_move = false
	pattern_active = true

	if launcher:
		launcher.start_pattern(current_segment.pattern_index)

	var duration := current_segment.get_duration()
	segment_end_time = FSM.state_time + duration
	next_move_time = FSM.state_time + max(current_segment.move_interval, 0.1)


func finish_segment():
	if launcher:
		launcher.stop_current_pattern()
	pattern_active = false


func get_current_segment() -> BossAttackSegment:
	if not attack_segments.is_empty():
		if attack_segments.size() == 1:
			last_segment_index = 0
			return attack_segments[0]
		var index: int
		while true:
			index = randi() % attack_segments.size()
			if index != last_segment_index:
				break
		last_segment_index = index
		return attack_segments[index]

	var fallback := BossAttackSegment.new()
	fallback.pattern_index = last_segment_index + 1
	fallback.duration_min = default_duration_min
	fallback.duration_max = default_duration_max
	fallback.move_before_attack = true
	fallback.move_during_attack = false
	fallback.move_interval = default_move_interval
	fallback.move_time = default_move_time
	return fallback


func move_to_new_position(duration: float):
	stop_move_tween()
	var target_pos := get_random_target_pos()
	move_tween = create_tween()
	move_tween.tween_property(amiya, "position", target_pos, duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


func stop_move_tween():
	if move_tween and move_tween.is_valid():
		move_tween.kill()


func get_random_target_pos() -> Vector2:
	var area_min := move_area_min
	var area_max := move_area_max

	if area_min.x > area_max.x:
		var temp_x := area_min.x
		area_min.x = area_max.x
		area_max.x = temp_x
	if area_min.y > area_max.y:
		var temp_y := area_min.y
		area_min.y = area_max.y
		area_max.y = temp_y

	for attempt in range(50):
		var target_pos := Vector2(
			randf_range(area_min.x, area_max.x),
			randf_range(area_min.y, area_max.y)
		)
		if amiya.position.distance_to(target_pos) >= min_move_distance:
			return target_pos

	return (area_min + area_max) / 2.0
