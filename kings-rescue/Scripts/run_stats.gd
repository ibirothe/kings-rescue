extends Node2D
const SAVE_PATH = "user://game_save.dat"
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

func _ready() -> void:
	load_game()

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
	save_game()

func add_loss() -> void:
	if upgrade_items.has("Hourglass"):
		upgrade_items.erase("Hourglass")
		return
	losses += 1
	streak = 0
	clear_shop()
	clear_upgrades()
	coins = 0
	save_game()

func add_shop_item(item) -> void:
	if shop_items.size() == 3:
		shop_items.pop_front()
	shop_items.append(item)

func clear_shop() -> void:
	shop_items = []

func clear_upgrades() -> void:
	upgrade_items = []

func save_game() -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		printerr("Failed to open save file: ", FileAccess.get_open_error())
		return
	
	# Create a dictionary with all the variables we want to save
	var save_data = {
		"difficulty": difficulty,
		"wins": wins,
		"losses": losses,
		"streak": streak,
		"coins": coins,
		"shop_items": shop_items,
		"upgrade_items": upgrade_items
	}
	
	# Convert to JSON and save
	var json_string = JSON.stringify(save_data)
	save_file.store_line(json_string)
	print("Game saved successfully")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found - using default values")
		return
	
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		printerr("Failed to open save file: ", FileAccess.get_open_error())
		return
	
	# Parse JSON data
	var json_string = save_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		printerr("JSON Parse Error: ", json.get_error_message())
		return
	
	# Get the data
	var save_data = json.get_data()
	
	# Apply loaded data to game variables
	difficulty = save_data.get("difficulty")
	wins = save_data.get("wins")
	losses = save_data.get("losses")
	streak = save_data.get("streak")
	coins = save_data.get("coins")
	shop_items = save_data.get("shop_items")
	upgrade_items = save_data.get("upgrade_items")
	
	print("Game loaded successfully")
	
func reset_save_file() -> void:
	difficulty = 0
	#run metrics:
	wins = 0
	losses = 0
	streak = 0

	#shop:
	coins = 100
	shop_items = ["Life Insurance"]
	#upgrades:
	upgrade_items = []
	save_game()
