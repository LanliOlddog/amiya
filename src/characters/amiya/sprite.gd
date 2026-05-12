extends Sprite2D

# ====== 可调参数 ======

@export var enter_pos: Vector2 = Vector2(200, 300)   # 入镜位置
@export var start_pos: Vector2 = Vector2(-600, 300)  # 初始屏幕外位置
@export var exit_pos: Vector2 = Vector2(2200, 300)   # 出镜位置

@export var enter_time: float = 0.6   # 入镜时长
@export var stay_time: float = 1.8    # 停留时间
@export var exit_time: float = 0.6    # 出镜时长

@export var fade_in_time: float = 0.6
@export var fade_out_time: float = 0.5

# 是否在开始时立即播放
@export var play_on_ready: bool = false


# ====== 生命周期 ======

func _ready():
	position = start_pos
	modulate.a = 0.0

	if play_on_ready:
		play_intro()


# ====== 动画播放 ======

func play_intro() -> void:
	var tween := create_tween()
	tween.set_parallel(false)  # 串行动画，每段顺序执行

	# --- 入镜 + 淡入 ---
	tween.parallel().tween_property(self, "position", enter_pos, enter_time)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(self, "modulate:a", 1.0, fade_in_time)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.tween_interval(stay_time)

	# --- 出镜 + 淡出 ---
	tween.parallel().tween_property(self, "position", exit_pos, exit_time)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	tween.parallel().tween_property(self, "modulate:a", 0.0, fade_out_time)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)


# ====== 外部调用接口 ======

func play_and_wait() -> Signal:
	play_intro()
	return get_tree().create_timer(exit_time).timeout

func reset():
	position = start_pos
