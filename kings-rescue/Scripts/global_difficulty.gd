extends Node2D
var difficulty = 0
#run metrics:
var wins = 0
var losses = 0
var streak = 0

#shop:
var coins = 100
var shop_items = []
#upgrades:
var upgrade_items = []

func difficulty_name() -> String:
	match difficulty:
		0: return "Baby Mode"
		1: return "Still Easy"
		2: return "Normie"
		3: return "Keyboard Smasher"
		4: return "Rage Quit"
		5: return "Masochist"
	return "God Mode"

func add_win() -> void:
	wins += 1
	streak += 1

func add_loss() -> void:
	if upgrade_items.has("Hourglass"):
		upgrade_items.erase("Hourglass")
		return
	losses += 1
	streak = 0
	clear_shop()
	clear_upgrades()
	coins = 0

func add_shop_item(item) -> void:
	if shop_items.size() == 3:
		shop_items.pop_front()
	shop_items.append(item)

func clear_shop() -> void:
	shop_items = []

func clear_upgrades() -> void:
	upgrade_items = []
