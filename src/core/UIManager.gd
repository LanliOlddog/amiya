extends Control

@export_group("右侧信息栏")
@export var stage_score: int = 0
@export var total_score: int = 0
@export var lives: int = 3
@export var bombs: int = 3
@export var power: float = 0.0

@onready var stage_score_label: Label = $RightPanel/Info/StageScoreLabel
@onready var total_score_label: Label = $RightPanel/Info/TotalScoreLabel
@onready var lives_label: Label = $RightPanel/Info/LivesLabel
@onready var bombs_label: Label = $RightPanel/Info/BombsLabel
@onready var power_label: Label = $RightPanel/Info/PowerLabel


func _ready() -> void:
	refresh_status_panel()


func set_scores(new_stage_score: int, new_total_score: int):
	stage_score = new_stage_score
	total_score = new_total_score
	refresh_status_panel()


func set_player_resources(new_lives: int, new_bombs: int, new_power: float):
	lives = new_lives
	bombs = new_bombs
	power = new_power
	refresh_status_panel()


func add_score(amount: int):
	stage_score += amount
	total_score += amount
	refresh_status_panel()


func add_power(amount: float):
	power += amount
	refresh_status_panel()


func refresh_status_panel():
	if not is_inside_tree():
		return
	stage_score_label.text = "STAGE SCORE  %010d" % stage_score
	total_score_label.text = "TOTAL SCORE  %010d" % total_score
	lives_label.text = "LIFE         %d" % lives
	bombs_label.text = "BOMB         %d" % bombs
	power_label.text = "HOPE        %.2f" % power
