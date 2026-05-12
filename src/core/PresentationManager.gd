extends CanvasLayer

signal portrait_finished
signal text_finished
signal dialogue_finished

@export_group("音效")
@export var spellcard_announcement_sound: StringName = &"spellcard_activatived"

@export_group("立绘动画")
@export var portrait_start_pos: Vector2 = Vector2(3470, -261)
@export var portrait_enter_pos: Vector2 = Vector2(1717, 881)
@export var portrait_exit_pos: Vector2 = Vector2(-203, 2296)
@export var portrait_enter_time: float = 0.6
@export var portrait_stay_time: float = 2.8
@export var portrait_exit_time: float = 0.6
@export var portrait_fade_in_time: float = 0.6
@export var portrait_fade_out_time: float = 0.5

@export_group("文本展示")
@export var text_position: Vector2 = Vector2(1280, 200)
@export var text_font_size: int = 56
@export var text_stay_time: float = 2.0
@export var text_fade_time: float = 0.25

@export_group("对话框")
@export var dialogue_position: Vector2 = Vector2(180, 1110)
@export var dialogue_size: Vector2 = Vector2(1500, 190)
@export var dialogue_font_size: int = 34

var current_portrait: Sprite2D
var current_text: Label
var current_dialogue_box: Control
var current_portrait_tween: Tween
var current_text_tween: Tween


func show_spellcard_announcement(sp: Spellcard) -> Signal:
	if spellcard_announcement_sound != &"":
		AudioManager.play_sound(String(spellcard_announcement_sound), 0.0)
		print("1111")
	return show_portrait(sp.sprite_texture)


func show_portrait(texture: Texture2D) -> Signal:
	clear_portrait()
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = portrait_start_pos
	sprite.modulate.a = 0.0
	add_child(sprite)
	current_portrait = sprite
	play_portrait_intro(sprite)
	return portrait_finished


func play_portrait_intro(sprite: Sprite2D):
	var portrait_id := sprite.get_instance_id()
	var tween := create_tween()
	current_portrait_tween = tween
	tween.set_parallel(false)
	tween.parallel().tween_property(sprite, "position", portrait_enter_pos, portrait_enter_time)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "modulate:a", 1.0, portrait_fade_in_time)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(portrait_stay_time)
	tween.parallel().tween_property(sprite, "position", portrait_exit_pos, portrait_exit_time)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, portrait_fade_out_time)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(_finish_portrait.bind(portrait_id))


func _finish_portrait(portrait_id: int):
	var sprite := instance_from_id(portrait_id) as Sprite2D
	if is_instance_valid(sprite):
		sprite.queue_free()
	if current_portrait == sprite:
		current_portrait = null
	current_portrait_tween = null
	portrait_finished.emit()


func show_text(text: String) -> Signal:
	clear_text()
	var label := Label.new()
	label.text = text
	label.position = text_position
	label.modulate.a = 0.0
	label.add_theme_font_size_override("font_size", text_font_size)
	add_child(label)
	current_text = label

	var text_id := label.get_instance_id()
	var tween := create_tween()
	current_text_tween = tween
	tween.tween_property(label, "modulate:a", 1.0, text_fade_time)
	tween.tween_interval(text_stay_time)
	tween.tween_property(label, "modulate:a", 0.0, text_fade_time)
	tween.tween_callback(_finish_text.bind(text_id))
	return text_finished


func _finish_text(text_id: int):
	var label := instance_from_id(text_id) as Label
	if is_instance_valid(label):
		label.queue_free()
	if current_text == label:
		current_text = null
	current_text_tween = null
	text_finished.emit()


func show_dialogue(speaker: String, line: String) -> Signal:
	clear_dialogue()
	var panel := PanelContainer.new()
	panel.position = dialogue_position
	panel.size = dialogue_size
	add_child(panel)

	var labels := VBoxContainer.new()
	panel.add_child(labels)

	var speaker_label := Label.new()
	speaker_label.text = speaker
	speaker_label.add_theme_font_size_override("font_size", dialogue_font_size)
	labels.add_child(speaker_label)

	var line_label := Label.new()
	line_label.text = line
	line_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line_label.add_theme_font_size_override("font_size", dialogue_font_size)
	labels.add_child(line_label)

	current_dialogue_box = panel
	return dialogue_finished


func advance_dialogue():
	clear_dialogue()
	dialogue_finished.emit()


func clear_portrait():
	if current_portrait_tween and current_portrait_tween.is_valid():
		current_portrait_tween.kill()
	current_portrait_tween = null
	if current_portrait and is_instance_valid(current_portrait):
		current_portrait.queue_free()
	current_portrait = null


func clear_text():
	if current_text_tween and current_text_tween.is_valid():
		current_text_tween.kill()
	current_text_tween = null
	if current_text and is_instance_valid(current_text):
		current_text.queue_free()
	current_text = null


func clear_dialogue():
	if current_dialogue_box and is_instance_valid(current_dialogue_box):
		current_dialogue_box.queue_free()
	current_dialogue_box = null


func clear_all():
	clear_portrait()
	clear_text()
	clear_dialogue()
