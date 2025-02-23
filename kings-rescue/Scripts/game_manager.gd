extends Node2D
var soldier_scene = preload("res://Scenes/soldier.tscn")
var coin_scene = preload("res://Scenes/coin.tscn")
var food_scene = preload("res://Scenes/food.tscn")
var informant_scene = preload("res://Scenes/informant.tscn")
var trap_scene = preload("res://Scenes/trap.tscn")
var rng = RandomNumberGenerator.new()
var subclasses = ["Rupert", "Thoralf", "Ogra", "Bartholo", "Ibrahim", "Edwin", "Marquise", "Arianna"]
var roles = ["Mercenary", "Mercenary", "Assassin", "Assassin", "Soldier", "Soldier", "Soldier", "Soldier"]
var x = 0  # Initialize x
var y = 0  # Initialize y
var occupied_positions = []
var food = 10
var setup_done = false
#@export var soldier: PackedScene
var soldier_in_a_way = false
var skip_cycle = true
var active_soldier: bool
var soldier_changing = false
var click_resolved = true
var cycle_odd = true
var currently_moving = false
var party_ended = false
@export var coins_number = 8
@export var food_number = 5
@export var trap_number = 20
@export var informant_number = 2
@onready var king: CharacterBody2D = $"../King"
var informantion = []
var magic = false

func _ready() -> void:
	AudioManager.play_sound("ambience",0.0,1.0,true)
	AudioManager.play_music("bg_music", -10.5)
	#active_soldier = false
	x=king.position.x-16
	y=king.position.y-16
	if setup_done == false:
		spawn_soldiers()
		spawn_coins(coins_number)
		spawn_food(food_number)
		spawn_informant(informant_number)
		spawn_traps(trap_number)
		setup_done = true
	

func _physics_process(delta: float) -> void:
	#print(active_soldier, " ", click_resolved, " ", currently_moving)
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
		party_ended = true
		AudioManager.stop_music()
		GlobalText.set_text("Your food stores are depleted. The soldiers begin to fall one by one—and soon, the king does as well. If you only listened to my instructions...", "Game Over",)
	if Input.is_action_just_pressed("Restart"):
		get_tree().reload_current_scene()
		Engine.time_scale = 1
	if cycle_odd == true:
		cycle_odd = false
	else:
		cycle_odd == true

	if soldier_in_a_way == true:
		#print("in a way ", soldier_in_a_way, "; active ", active_soldier, "; changing ", soldier_changing)
		if skip_cycle == true:
			pass
			skip_cycle = false
		else:
			soldier_in_a_way = false
			skip_cycle = true
			soldier_changing = false
	if click_resolved == true:
		if skip_cycle == true:
			pass
			skip_cycle = false
		else:
			click_resolved = false
			skip_cycle = true

		

func spawn_soldiers():
	for i in range(8):
		var soldier = soldier_scene.instantiate()
		var j = round(randf_range(0, len(subclasses)-1))
		#print(j)
		var subclass = subclasses[j]
		soldier.subclass = subclass
		subclasses.erase(subclass)
		var k = round(randf_range(0, len(roles)-1))
		var role = roles[k]
		if role == "Assassin":
			soldier.assassin = true
			informantion.append(subclass+ " is an assassin.")
		elif role == "Mercenary":
			soldier.mercenary = true
			soldier.role = "Soldier"
		else:
			soldier.role = "Soldier"
		roles.erase(role)
		
		
		match i:
			0:
				pass
			1: 
				x += 16
			2: 
				x += 16
			3: 
				y += 16
			4: 
				y += 16
			5: 
				x -= 16
			6: 
				x -= 16
			7: 
				y -= 16
		
		soldier.position = Vector2(x, y)
		add_child(soldier)
		
		
func spawn_coins(coins_numb):
	var i = 0
	while i < coins_numb:
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
	while i < food_numb:
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
	while i < traps_numb:
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

func movement_resolved(possible_assassination, soldier_close):
	if possible_assassination == true and soldier_close == false:
		print("Game Over")
	pass
	#currently_moving = false
	#connect signals
	#check game over
	#disconnect signals

func refire_king():
	king.king()
