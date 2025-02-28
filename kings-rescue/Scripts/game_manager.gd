extends Node2D
var coin_scene = preload("res://Scenes/coin.tscn")
var food_scene = preload("res://Scenes/food.tscn")
var informant_scene = preload("res://Scenes/informant.tscn")
var trap_scene = preload("res://Scenes/trap.tscn")
var x = 0  # Initialize x
var y = 0  # Initialize y
var occupied_positions = []
var food = 10
var setup_done = false
var active_soldier: bool
var currently_moving = false
var party_ended = false
@export var coins_number = 6
@export var food_number = 7
@export var trap_number = 14
@export var informant_number = 2
@onready var king: CharacterBody2D = $"../King"
var informantion = []
var magic = false
@onready var win_lose_label: Label = $"../CanvasLayer/Win-lose-label"
@onready var color_rect: ColorRect = $"../CanvasLayer/ColorRect"
@onready var troop = $"../Game Manager/Troop"
var inside_board = false


func _ready() -> void:
	AudioManager.play_sound("ambience",0.0,1.0,true)
	AudioManager.play_music("bg_music", -10.5)
	color_rect.color = Color(0, 0, 0, 0)  # Initialize with transparent black
	#active_soldier = false
	x=king.position.x-16
	y=king.position.y-16
	if setup_done == false:
		troop.spawn_soldiers()
		spawn_coins(coins_number)
		spawn_food(food_number)
		spawn_informant(informant_number)
		spawn_traps(trap_number)
		setup_done = true
		win_lose_label.modulate.a = 0
	

func _physics_process(delta: float) -> void:
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
		
		AudioManager.stop_music()
		if party_ended == false:
			GlobalDifficulty.losses +=1
			GlobalText.set_text("")
			var lose_text = "Your food stores are depleted. The soldiers begin to fall one by one-and soon, the king does as well. If you only listened to my instructions... \n \nWINS: " + str(GlobalDifficulty.wins) + "\n \nLOSSES: " + str(GlobalDifficulty.losses) + "\n \nDIFFICULTY: " + str(GlobalDifficulty.difficulty_name()) + "\n \nHistory keeps repeating itself! Press 'R' to retry and keep an eye on your Food Rations"
			win_fade_out(lose_text)
			party_ended = true

	if Input.is_action_just_pressed("Restart"):
		get_tree().reload_current_scene()

	if Input.is_action_just_pressed("Help"):
		GlobalText.set_text("An assassination plot has been uncovered! Click to select a Soldier and move them. Soldiers can push the King to escort him safely from the board-but beware, if an Assassin gets close, only a Soldier standing next to them can stop the deadly strike.", "Starter Guide")
	
		
func spawn_coins(coins_numb):
	var i = 0
	while i < coins_numb + GlobalDifficulty.difficulty:
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
	while i < max(0, food_numb - GlobalDifficulty.difficulty):
		var food = food_scene.instantiate()
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
				food.position = pos
				occupied_positions.append(pos)
				add_child(food)

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
	while i < traps_numb + 2 * GlobalDifficulty.difficulty:
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

func refire_king():
	king.king()

func win_fade_out(display_text, wait_time = 1.8):
	# Wait for the timer to complete before proceeding
	await get_tree().create_timer(wait_time).timeout
	
	print("Fade out")
	# Screen fade
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	# Fade from transparent to black
	tween.tween_property(color_rect, "color", Color(0, 0, 0, 1), 1.0)
	await tween.finished
	# Short pause
	await get_tree().create_timer(0.5).timeout
	
	if win_lose_label:
		var text_tween = create_tween()
		text_tween.tween_property(win_lose_label, "modulate:a", 1.0, 1.0)
		GlobalText.set_text(display_text)
		

func _on_boardclickarea_mouse_entered() -> void:
	inside_board = true
	pass # Replace with function body.


func _on_boardclickarea_mouse_exited() -> void:
	inside_board = false
