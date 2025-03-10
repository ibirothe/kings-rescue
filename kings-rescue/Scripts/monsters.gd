extends Node2D
var subclasses = ["Rupert", "Thoralf", "Ogra", "Bartholo", "Ibrahim", "Edwin", "Marquise", "Arianna"]
var roles = ["Mercenary", "Mercenary", "Assassin", "Assassin", "Soldier", "Soldier", "Soldier", "Soldier"]
var movement_click = false
var movement_direction = []
var moving_soldier = []
var activating_soldier
var activation_click = false
var click_resolved = true
var current_soldier
@export var dog_scene: PackedScene
@export var goblin_scene: PackedScene
var j = 0
var x = 0  # Initialize x
var y = 0  # Initialize y
var setup_done = false
@onready var game_manager = get_parent()
var soldiers = []
var move_dir: Vector2
var direct
@onready var king: CharacterBody2D = $"../../King"
var doggo_directions = []
var buddy
var monsters = []
var canine_numb
var action_queue = []
var current_monster
var direct_text
var goblin_numb
var found_trap = false
var recursion = 0
var occupied_spaces = []


func spawn_doggos(canine_numb):
	var i = 0
	while i < canine_numb + 2 * RunStats.difficulty:
		var doggo = dog_scene.instantiate()
		x = round(randf_range(0, 10))
		y = round(randf_range(0, 10))
		if x > 2 and y > 2 and x < 8 and y < 8:
			pass
		else:
			x = king.position.x-(5*16) + x*16
			y = king.position.y+(5*16) - y*16
			var pos = Vector2(x, y)
			if pos not in game_manager.occupied_positions:

				i += 1
				doggo.position = pos
				game_manager.occupied_positions.append(pos)
				add_child(doggo)
				doggo.number = i-1
				if x > 0:
					direct = Vector2(-16, 0)
				else:
					direct = Vector2(16, 0)
				monsters.append(doggo)
				doggo.directions = direct
				var direction = _get_direction("dog", doggo)

					
func spawn_goblins(goblin_numb):
	var i = 0
	while i < goblin_numb + 2 * RunStats.difficulty:
		var gobbo = goblin_scene.instantiate()
		x = round(randf_range(0, 10))
		y = round(randf_range(0, 10))
		if x > 2 and y > 2 and x < 8 and y < 8:
			pass
		else:
			x = king.position.x-(5*16) + x*16
			y = king.position.y+(5*16) - y*16
			var pos = Vector2(x, y)
			if pos not in game_manager.occupied_positions:

				i += 1
				gobbo.position = pos
				game_manager.occupied_positions.append(pos)
				add_child(gobbo)
				gobbo.number = i-1
				if x > 0:
					direct = Vector2(-16, 0)
				else:
					direct = Vector2(16, 0)
				monsters.append(gobbo)

func _physics_process(_delta: float) -> void:
	if len(action_queue) > 0:
		for buddy in monsters:
			buddy.move(buddy)
			action_queue.erase("move")
	pass
	
func move_all():
	occupied_spaces = []
	action_queue.append("move")

		
func _get_direction(monster_type, current_monster):
	if monster_type == "goblin":
		return goblin_ai(current_monster)
	if monster_type == "dog":
		check_occupied(current_monster, direct)
		


		
func goblin_ai(goblin):
	goblin.find_coins()
	if goblin.find_nearest_coin() == null or detour():
		#print("taking detour")
		recursion = 0
		found_trap = false
		return rand_goblin_directions(goblin)
	else:
		var basic_direction = goblin.find_nearest_coin().center.global_position-goblin.center.global_position
		#print(basic_direction)
		var rand = randf_range(0, 100)
		if basic_direction.x > 0:
			direct = Vector2(16, 0)
			direct_text = "right"
		else:
			direct = Vector2(-16, 0)
			direct_text = "left"
		if basic_direction.y != 0:
			if rand > 50 or basic_direction.x == 0:
				if basic_direction.y > 0:
					direct = Vector2(0, 16)
					direct_text = "down"
				else:
					direct = Vector2(0, -16)
					direct_text = "up"
		rand = randf_range(0, 100)
		if goblin._check_traps(direct_text) == "trap" and rand > 20:
			found_trap = true
			recursion += 1
			return goblin_ai(goblin)
		else:
			#print("Moving towards coin ", direct_text)
			recursion = 0
			found_trap = false
			#print("Bad goblin luck")
			goblin.old_direct = direct
			return(direct)
		
func detour():
	if found_trap and recursion >2:
		#print("Taking detour")
		return true
	else:
		return false
	
		
func rand_goblin_directions(goblin):
	var rand_directions = str(round(randf_range(0,3)))
	match rand_directions:
		"0": 
			direct = Vector2(-16, 0)
			direct_text = "left"
		"1":
			direct = Vector2(16, 0)
			direct_text = "right"
		"2":
			direct = Vector2(0, -16)
			direct_text = "up"
		"3":
			direct = Vector2(0, 16)
			direct_text = "down"
	#print("Moving randomly")
	var random = randf_range(0, 99)
	if direct == goblin.old_direct * (-1) and random > 20:
		return rand_goblin_directions(goblin)
	elif goblin._check_traps(direct_text) == "trap" and random > 20:
		return rand_goblin_directions(goblin)
	else:
			goblin.old_direct = direct
			return direct
			
func check_occupied(monster, direct):
		var new_position = monster.global_position + direct
		if new_position not in occupied_spaces:
			occupied_spaces.append(new_position)
			return(direct)
		else:
			monster.non_occupied = false
			return(direct)
