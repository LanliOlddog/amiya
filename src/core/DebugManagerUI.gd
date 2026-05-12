extends CanvasLayer

@export var bgm_names: Array[String] = ["已至", "红楼"]
@export var bgm_streams: Array[AudioStream] = []
@export var state_names: Array[String] = ["idle", "nonspell", "atk", "transition", "spellcards"]
@export var pattern_names: Array[String] = [
	"Gaster",
	"skillA",
	"skillB",
	"skillc",
	"MoonWreath",
	"FanSweep",
	"FlowerRain",
	"SniperBurst"
]
@export var player_level_names: Array[String] = ["level1", "level2", "level3"]
@export var drop_type_names: Array[String] = ["power", "score"]
@export var damage_amount: float = 10.0
@export var debug_drop_boss_offset: Vector2 = Vector2(0.0, 140.0)
@export var debug_drop_spread: Vector2 = Vector2(48.0, 32.0)

var debug_controls_visible: bool = true

@onready var bgm_options: OptionButton = $Panel/BGM
@onready var state_options: OptionButton = $Panel/ChoseState
@onready var hurt_button: Button = $Panel/Hurt
@onready var pattern_options: OptionButton = $Panel/ChoseSkill
@onready var player_level_options: OptionButton = $Panel/PlayerLevel
@onready var spellcard_presentation_button: Button = $Panel/SpellcardPresentation
@onready var drop_type_options: OptionButton = $Panel/DropType
@onready var spawn_drop_button: Button = $Panel/SpawnDrop
@onready var debug_controls_toggle_button: Button = $Panel/ToggleDebugControls


func _ready() -> void:
	setup_options(bgm_options, bgm_names)
	setup_options(state_options, state_names)
	setup_options(pattern_options, pattern_names)
	setup_options(player_level_options, player_level_names)
	setup_options(drop_type_options, drop_type_names)
	update_debug_controls_visibility()
	connect_controls()


func setup_options(options: OptionButton, names: Array[String]):
	options.clear()
	for i in range(names.size()):
		options.add_item(names[i], i)


func connect_controls():
	if not bgm_options.item_selected.is_connected(_on_bgm_selected):
		bgm_options.item_selected.connect(_on_bgm_selected)
	if not state_options.item_selected.is_connected(_on_state_selected):
		state_options.item_selected.connect(_on_state_selected)
	if not hurt_button.pressed.is_connected(_on_hurt_pressed):
		hurt_button.pressed.connect(_on_hurt_pressed)
	if not pattern_options.item_selected.is_connected(_on_pattern_selected):
		pattern_options.item_selected.connect(_on_pattern_selected)
	if not player_level_options.item_selected.is_connected(_on_player_level_selected):
		player_level_options.item_selected.connect(_on_player_level_selected)
	if not spellcard_presentation_button.pressed.is_connected(_on_spellcard_presentation_pressed):
		spellcard_presentation_button.pressed.connect(_on_spellcard_presentation_pressed)
	if not spawn_drop_button.pressed.is_connected(_on_spawn_drop_pressed):
		spawn_drop_button.pressed.connect(_on_spawn_drop_pressed)
	if not debug_controls_toggle_button.pressed.is_connected(_on_debug_controls_toggle_pressed):
		debug_controls_toggle_button.pressed.connect(_on_debug_controls_toggle_pressed)


func get_debug_controls() -> Array[Control]:
	return [
		bgm_options,
		state_options,
		hurt_button,
		pattern_options,
		player_level_options,
		spellcard_presentation_button,
		drop_type_options,
		spawn_drop_button
	]


func update_debug_controls_visibility():
	for control in get_debug_controls():
		control.visible = debug_controls_visible
	debug_controls_toggle_button.text = "隐藏调试控件" if debug_controls_visible else "显示调试控件"


func _on_bgm_selected(index: int):
	if index < 0 or index >= bgm_streams.size():
		return
	DebugManager.select_bgm(index, bgm_streams[index])


func _on_state_selected(index: int):
	DebugManager.select_boss_state(index)


func _on_hurt_pressed():
	DebugManager.damage_boss(damage_amount)


func _on_pattern_selected(index: int):
	DebugManager.select_boss_pattern(index)


func _on_player_level_selected(index: int):
	DebugManager.select_player_level(index)


func _on_spellcard_presentation_pressed():
	DebugManager.play_spellcard_presentation()


func _on_spawn_drop_pressed():
	var selected_index := drop_type_options.selected
	if selected_index < 0 or selected_index >= drop_type_names.size():
		return

	var boss := get_drop_spawn_boss()
	if boss:
		DropManager.spawn_drop_from_node(
			StringName(drop_type_names[selected_index]),
			boss,
			debug_drop_boss_offset,
			1,
			debug_drop_spread
		)
		return

	DropManager.spawn_drop(StringName(drop_type_names[selected_index]), get_viewport().get_visible_rect().size * 0.5, 1, debug_drop_spread)


func get_drop_spawn_boss() -> Node2D:
	if is_instance_valid(DebugManager.boss):
		return DebugManager.boss
	var amiya := get_node_or_null("/root/Game/Amiya") as Node2D
	if is_instance_valid(amiya):
		return amiya
	return null


func _on_debug_controls_toggle_pressed():
	debug_controls_visible = not debug_controls_visible
	update_debug_controls_visibility()
