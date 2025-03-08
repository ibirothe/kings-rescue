extends Node2D
@onready var win_label = $"WinLabel"

@onready var labels = [win_label]
@onready var crowns = [
	$"Crowns/Crown01",
	$"Crowns/Crown02",
	$"Crowns/Crown03",
	$"Crowns/Crown04",
	$"Crowns/Crown05"
	]

func _ready() -> void:
	win_label.text = "Kings saved: " + str(RunStats.wins)
	
	for crown in crowns:
		if crowns.rfind(crown) == RunStats.difficulty and RunStats.stored_difficulty and RunStats.difficulty <= 5:
			RunStats.stored_difficulty = false
			crown.play("ignite")
		elif crowns.rfind(crown) <= RunStats.difficulty:
			crown.play("true")
		else:
			crown.play("false")
			
	for label in labels:
		await fade_in(label)

func fade_in(label) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(label, "modulate:a", 1, 0.6)
	await tween.finished
