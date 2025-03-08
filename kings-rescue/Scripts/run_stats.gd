extends Node2D
const SAVE_PATH = "user://game_save.dat"
var difficulty = 0

#run metrics:
var wins = 0
var hourglasses = 0
var soldiers_died = 0
var soldiers_fled = 0
var monsters_spawned = 0
var monsters_killed = 0

#stored events
var stored_loss = false
var stored_difficulty = false

#shop:
var coins = 100
var coins_spent = 0
var coins_total = 0
var shop_items = []

#upgrades:
var upgrade_items = []

func _ready() -> void:
	load_game()

func increase_difficulty():
	stored_difficulty = true
	difficulty = min(5, difficulty+1)

func add_win() -> void:
	wins += 1
	save_game()

func add_loss() -> void:
	if upgrade_items.has("Hourglass"):
		upgrade_items.erase("Hourglass")
		hourglasses += 1
		save_game()
		return
	stored_loss = true

func handle_loss() -> void:
	if stored_loss:
		reset_save_file()

func spend_coins(amount) -> void:
	coins -= amount
	coins_spent += amount

func add_coins(amount) -> void:
	coins += amount
	coins_total += amount

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
		"hourglasses": hourglasses,
		"stored_loss": stored_loss,
		"soldiers_died": soldiers_died,
		"soldiers_fled": soldiers_fled,
		"monsters_spawned": monsters_spawned,
		"monsters_killed": monsters_killed,
		"coins": coins,
		"coins_spent": coins_spent,
		"coins_total": coins_total,
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
	hourglasses = save_data.get("hourglasses")
	stored_loss = save_data.get("stored_loss")
	soldiers_died = save_data.get("soldiers_died")
	soldiers_fled = save_data.get("soldiers_fled")
	monsters_spawned = save_data.get("monsters_spawned")
	monsters_killed = save_data.get("monsters_killed")
	coins = save_data.get("coins")
	coins_spent = save_data.get("coins_spent")
	coins_total = save_data.get("coins_total")
	shop_items = save_data.get("shop_items")
	upgrade_items = save_data.get("upgrade_items")
	
	print("Game loaded successfully")
	
func reset_save_file() -> void:
	difficulty = 0
	#run metrics:
	wins = 3
	hourglasses = 0
	stored_loss = false
	soldiers_died = 0
	soldiers_fled = 0
	monsters_spawned = 0
	monsters_killed = 0

	#shop:
	coins = 0
	coins_spent = 0
	coins_total = 0
	shop_items = []
	#upgrades:
	upgrade_items = ["Hourglass", "Dimensional Key"]
	save_game()
