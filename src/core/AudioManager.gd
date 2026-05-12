extends Node

@export var musics:Array[AudioStreamPlayer] = []

@onready var SFX: Node = $SFX

var current_BGM:AudioStreamPlayer = null
var next_BGM:AudioStreamPlayer = null
var BGM_tween:Tween

#---BGM管理器
func set_BGM(bgm:AudioStream):
	if bgm == null:
		return
	# 如果已经有下一个BGM在等待，取消之前的淡入淡出
	if BGM_tween != null and BGM_tween.is_valid():
		BGM_tween.kill()
	
	# 找到下一个可用的 AudioStreamPlayer
	var available_player: AudioStreamPlayer = null
	for player in musics:
		if player != current_BGM:
			available_player = player
			break
	
	# 如果没有可用的播放器，使用第一个
	if available_player == null and musics.size() > 0:
		available_player = musics[0]
	
	if available_player == null:
		return
	
	next_BGM = available_player
	next_BGM.stream = bgm
	
	# 如果当前有BGM在播放，淡出当前BGM
	if current_BGM != null and current_BGM.playing:
		BGM_tween = create_tween()
		BGM_tween.tween_property(current_BGM, "volume_db", -80.0, 0.5)
		BGM_tween.tween_callback(func(): 
			current_BGM.stop()
			current_BGM.volume_db = 0.0
		)
		# 等待当前BGM淡出完成后再启动新BGM
		BGM_tween.tween_callback(_start_next_BGM)
	else:
		# 直接启动新BGM
		_start_next_BGM()

func _start_next_BGM():
	if next_BGM == null:
		return
	# 设置当前BGM
	current_BGM = next_BGM
	# 设置初始音量为静音并开始播放
	current_BGM.volume_db = -80.0
	current_BGM.play()
	# 淡入效果
	BGM_tween = create_tween()
	BGM_tween.tween_property(current_BGM, "volume_db", 0.0, 0.5)


#音效管理器
var last_play_times = {}
func play_sound(s:String,limit_time:float = 2):
	var sound_to_play = SFX.get_node(s)
	var current_time = Time.get_ticks_msec() / 1000.0
	var last_time = last_play_times.get(s,0.0)
	if current_time - last_time < limit_time:
		return
	sound_to_play.play()
	last_play_times[s] = current_time

	
	
