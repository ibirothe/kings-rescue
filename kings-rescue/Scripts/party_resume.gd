extends Node2D
@onready var win_label = $"WinLabel"
@onready var hourglass_label = $"HourglassLabel"
@onready var coin_total_label = $"CoinTotalLabel"
@onready var coin_spent_label = $"CoinSpentLabel"
@onready var monsters_spawned_label = $"MonstersSpawnedLabel"
@onready var monsters_killed_label = $"MonstersKilledLabel"
@onready var soldiers_died_label = $"SoldiersDiedLabel"
@onready var soldiers_fled_label = $"SoldiersFledLabel"
@onready var game_over_label = $"GameOverLabel"

@onready var labels = [
	win_label,
	hourglass_label,
	monsters_spawned_label,
	monsters_killed_label,
	coin_total_label,
	coin_spent_label,
	soldiers_died_label,
	soldiers_fled_label
	]

@onready var crowns = [
	$"Crowns/Crown01",
	$"Crowns/Crown02",
	$"Crowns/Crown03",
	$"Crowns/Crown04",
	$"Crowns/Crown05"
	]

func _ready() -> void:
	win_label.text = "Kings saved: " + str(RunStats.wins)
	hourglass_label.text = "Hourglasses: " + str(RunStats.hourglasses)
	coin_spent_label.text = "Spent: "  + str(RunStats.coins_spent)
	coin_total_label.text = "Collected: "  + str(RunStats.coins_total)
	soldiers_died_label.text = "Fatalities: "  + str(RunStats.soldiers_died)
	soldiers_fled_label.text = "Desertations: "  + str(RunStats.soldiers_fled)
	monsters_spawned_label.text = "Spawned: "  + str(RunStats.monsters_spawned)
	monsters_killed_label.text = "Killed: "  + str(RunStats.monsters_killed)
	
	fade_in_labels()
	update_crowns()
	
	if RunStats.stored_loss:
		game_over_animation()
		count_down_labels()
	
	RunStats.handle_loss()

func game_over_animation() -> void:
	await get_tree().create_timer(1.6).timeout
	fade_in(game_over_label)
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(game_over_label, "position:y", game_over_label.position.y - 25, 3)
	await get_tree().create_timer(2.5).timeout
	fade_out(game_over_label)

func count_down_labels() -> void:
	var max_count = max(
		RunStats.wins,
		RunStats.hourglasses,
		RunStats.coins_spent,
		RunStats.coins_total,
		RunStats.soldiers_died,
		RunStats.soldiers_fled,
		RunStats.monsters_spawned,
		RunStats.monsters_killed
		)
	var reverse_i = 0
	await get_tree().create_timer(7).timeout
	for i in range(max_count):
		await get_tree().create_timer(0.05).timeout
		AudioManager.play_sound("count_down_tick", 3)
		reverse_i += 1
		win_label.text = "Kings saved: " + str(max(0,RunStats.wins-reverse_i))
		hourglass_label.text = "Hourglasses: " + str(max(0,RunStats.hourglasses-reverse_i))
		coin_spent_label.text = "Spent: "  + str(max(0,RunStats.coins_spent-reverse_i))
		coin_total_label.text = "Collected: "  + str(max(0,RunStats.coins_total-reverse_i))
		soldiers_died_label.text = "Fatalities: "  + str(max(0,RunStats.soldiers_died-reverse_i))
		soldiers_fled_label.text = "Desertations: "  + str(max(0,RunStats.soldiers_fled-reverse_i))
		monsters_spawned_label.text = "Spawned: "  + str(max(0,RunStats.monsters_spawned-reverse_i))
		monsters_killed_label.text = "Killed: "  + str(max(0,RunStats.monsters_killed-reverse_i))
	AudioManager.play_sound("count_ends")

func update_crowns() -> void:
	for crown in crowns:
		if crowns.rfind(crown) == RunStats.difficulty and RunStats.stored_difficulty and RunStats.difficulty <= 5:
			RunStats.stored_difficulty = false
			crown.play("ignite")
			await get_tree().create_timer(1.6).timeout
			AudioManager.play_sound("ignite_crown")
		elif crowns.rfind(crown) <= RunStats.difficulty:
			crown.play("true")
		else:
			crown.play("false")

func fade_in_labels() -> void:
	await get_tree().create_timer(1.0).timeout
	for label in labels:
		await fade_in(label)

func fade_in(label) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(label, "modulate:a", 1, 0.4)
	await tween.finished

func fade_out(label) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(label, "modulate:a", 0, 0.4)
	await tween.finished
