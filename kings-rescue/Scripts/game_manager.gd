extends Node2D
var coin_scene = preload("res://Scenes/coin.tscn")
var food_scene = preload("res://Scenes/food.tscn")
var informant_scene = preload("res://Scenes/informant.tscn")
var trap_scene = preload("res://Scenes/trap.tscn")
var shop_item_scene = preload("res://Scenes/restock_item.tscn")
var door_scene = preload("res://Scenes/door.tscn")
var txt_scene = preload("res://Scenes/Texts.tscn")
var resume_scene = preload("res://Scenes/party_resume.tscn")
var x = 0  # Initialize x
var y = 0  # Initialize y
var occupied_positions = []
var food = 10
var setup_done = false
var active_soldier: bool
var currently_moving = false
var party_ended = false
var inside_board = false
var informantion = []
var magic = false

@export var coins_number = 6
@export var food_number = 7
@export var trap_number = 14
@export var informant_number = 2
@export var shop_item_number = 1
@export var canine_number = 0
@export var goblin_number = 1

@onready var king: CharacterBody2D = $"../King"
@onready var camera: Camera2D = $"../Camera2D"
@onready var troop = $"../Game Manager/Troop"
@onready var txt = txt_scene.instantiate()
@onready var monsters: Node2D = $Monsters


func _ready() -> void:
	AudioManager.play_sound("ambience",0.0,1.0,true)
	AudioManager.play_music("bg_music", -10.5)
	#active_soldier = false
	x=king.position.x-16
	y=king.position.y-16
	
	if RunStats.upgrade_items.has("Trained Chef"):
		food += 2

func _physics_process(delta: float) -> void:
	if setup_done == false:
		troop.spawn_soldiers()
		spawn_coins(coins_number)
		spawn_food(food_number)
		spawn_informant(informant_number)
		spawn_traps(trap_number)
		spawn_shop_item(shop_item_number)
		monsters.spawn_doggos(canine_number)
		monsters.spawn_goblins(goblin_number)
		spawn_difficulty_door()
		GlobalText.set_text(txt.ingame["start"].pick_random())
		setup_done = true
	
	if Input.is_action_just_pressed("Magic"):
		if magic == false:
			var trap = trap_scene.instantiate()
			x = king.position.x
			y = king.position.y
			var pos = Vector2(x, y)
			trap.position = pos
			add_child(trap)
			magic = true
	if food == 0:
		if party_ended == false:
			end_party("starvation", false)

	if Input.is_action_just_pressed("Restart"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("Delete"):
		RunStats.reset_save_file()
		RunStats.load_game()
		get_tree().reload_current_scene()

	if Input.is_action_just_pressed("Help"):
		GlobalText.set_text(txt.ingame["start"].pick_random())
	
		
func spawn_coins(coins_numb):
	var i = 0
	while i < coins_numb + RunStats.difficulty:
		var coin = coin_scene.instantiate()
		x = round(randf_range(0, 10))
		y = round(randf_range(0, 10))
		
		if x > 2 and y > 2 and x < 8 and y < 8:
			pass
		else:
			x = king.position.x-(5*16) + x*16
			y = king.position.y+(5*16) - y*16
			var pos = Vector2(x, y)
			
			if pos not in occupied_positions:
				i += 1
				coin.position = pos
				occupied_positions.append(pos)
				add_child(coin)

func spawn_food(food_numb):
	var i = 0
	while i < max(0, food_numb - RunStats.difficulty):
		var food_item = food_scene.instantiate()
		x = round(randf_range(0, 10))
		y = round(randf_range(0, 10))
		
		if x > 2 and y > 2 and x < 8 and y < 8:
			pass
		else:
			x = king.position.x-(5*16) + x*16
			y = king.position.y+(5*16) - y*16
			var pos = Vector2(x, y)
			
			if pos not in occupied_positions:
				i += 1
				food_item.position = pos
				occupied_positions.append(pos)
				add_child(food_item)

func spawn_informant(informant_numb):
	var i = 0
	while i < informant_numb:
		var informant = informant_scene.instantiate()
		x = round(randf_range(0, 10))
		y = round(randf_range(0, 10))
		informant.info = informantion[i]
		if x > 2 and y > 2 and x < 8 and y < 8:
			pass
		else:
			x = king.position.x-(5*16) + x*16
			y = king.position.y+(5*16) - y*16
			var pos = Vector2(x, y)
			
			if pos not in occupied_positions:
				i += 1
				informant.position = pos
				occupied_positions.append(pos)
				add_child(informant)

func spawn_traps(traps_numb):
	var i = 0
	while i < traps_numb + 2 * RunStats.difficulty:
		var trap = trap_scene.instantiate()
		x = round(randf_range(0, 10))
		y = round(randf_range(0, 10))
		
		if x > 2 and y > 2 and x < 8 and y < 8:
			pass
		else:
			x = king.position.x-(5*16) + x*16
			y = king.position.y+(5*16) - y*16
			var pos = Vector2(x, y)
			
			if pos not in occupied_positions:
				i += 1
				trap.position = pos
				occupied_positions.append(pos)
				add_child(trap)

func spawn_shop_item(amount):
	var i = 0
	
	while i < amount:
		var x = round(randf_range(0, 10))
		var y = round(randf_range(0, 10))
		
		# Skip central area and generate new coordinates
		if x > 2 and y > 2 and x < 8 and y < 8:
			continue
			
		var pos_x = king.position.x-(5*16) + x*16
		var pos_y = king.position.y+(5*16) - y*16
		var pos = Vector2(pos_x, pos_y)
		
		if pos not in occupied_positions:
			i += 1
			var shop_item = shop_item_scene.instantiate()
			shop_item.position = pos
			occupied_positions.append(pos)
			add_child(shop_item)
	
	# spawn mimic (with probability)
	if randi_range(0,10) >= 8:
		var x = round(randf_range(0, 10))
		var y = round(randf_range(0, 10))
		
		# Skip central area and generate new coordinates
		if x > 2 and y > 2 and x < 8 and y < 8:
			return
			
		var pos_x = king.position.x-(5*16) + x*16
		var pos_y = king.position.y+(5*16) - y*16
		var pos = Vector2(pos_x, pos_y)
		
		if pos not in occupied_positions:
			var mimic_shop_item = shop_item_scene.instantiate()
			mimic_shop_item.position = pos
			mimic_shop_item.mimic = true
			occupied_positions.append(pos)
			add_child(mimic_shop_item)


func spawn_difficulty_door() -> void:
	if RunStats.upgrade_items.has("Dimensional Key") and RunStats.wins >= (RunStats.difficulty+1)*3:
		var i = 0
		while i < 1:
			var door = door_scene.instantiate()
			x = round(randf_range(0, 10))
			y = round(randf_range(0, 10))
			
			if x > 2 and y > 2 and x < 8 and y < 8:
				pass
			else:
				x = king.position.x-(5*16) + x*16
				y = king.position.y+(5*16) - y*16
				var pos = Vector2(x, y)
				
				if pos not in occupied_positions:
					i += 1
					door.position = pos
					occupied_positions.append(pos)
					add_child(door)

func refire_king():
	king.king()

func end_party(text_key, win) -> void:
	GlobalText.set_text("")
	AudioManager.stop_music()
	
	var text = txt.party_end[text_key].pick_random()

	if win:
		RunStats.add_win()
		AudioManager.play_music("win_jingle", -8, false)
	else:
		if RunStats.upgrade_items.has("Hourglass"):
			text = text + txt.ingame["Hourglass"].pick_random()
		RunStats.add_loss()
		AudioManager.play_music("lose_jingle", -8, false)

	win_fade_out(text)
	party_ended = true

func win_fade_out(display_text, wait_time = 1.8):
	# Wait for the timer to complete before proceeding
	await get_tree().create_timer(wait_time).timeout

	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	# Fade from transparent to black
	var party_resume = resume_scene.instantiate()
	party_resume.modulate.a = 0
	add_child(party_resume)
	tween.tween_property(party_resume, "modulate:a", 1, 1.2)
	await tween.finished
	# Short pause
	await get_tree().create_timer(0.5).timeout
	GlobalText.set_text(display_text)


func _on_boardclickarea_mouse_entered() -> void:
	inside_board = true


func _on_boardclickarea_mouse_exited() -> void:
	inside_board = false

func movement_complete():
	monsters.move_all()
	food = max(0, food-1)
	currently_moving = false
	
