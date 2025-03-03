extends Node2D
@onready var win_label = $"WinLabel"
@onready var loss_label = $"LossLabel"
@onready var streak_label = $"StreakLabel"
@onready var difficulty_label = $"DifficultyLabel"
@onready var labels = [win_label, streak_label, loss_label, difficulty_label]

func _ready() -> void:
	win_label.text = "Total Wins: " + str(RunStats.wins)
	streak_label.text = "Win Streak: " + str(RunStats.streak)
	loss_label.text = "Total Losses: " + str(RunStats.losses)
	difficulty_label.text = "Current Difficulty: " + RunStats.difficulty_name()
	
	for label in labels:
		await fade_in(label)
	
func fade_in(label) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(label, "modulate:a", 1, 0.6)
	await tween.finished
