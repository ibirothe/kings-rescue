extends Node2D
var soldier_scene = preload("res://Scenes/soldier.tscn")
var coin_scene = preload("res://Scenes/coin.tscn")
var rng = RandomNumberGenerator.new()
var subclasses = ["Rupert", "Thoralf", "Ogra", "Bartholo", "Ibrahim", "Edwin", "Marquise", "Arianna"]
var roles = ["Mercenary", "Mercenary", "Assassin", "Assassin", "Soldier", "Soldier", "Soldier", "Soldier"]
var x = 0  # Initialize x
var y = 0  # Initialize y
var setup_done = false
#@export var soldier: PackedScene
var soldier_in_a_way = false
var skip_cycle = true
var active_soldier: bool
var soldier_changing = false
var click_resolved = true
var cycle_odd = true
var currently_moving = false
@export var coins_number = 8
@onready var king: CharacterBody2D = $"../King"

func _ready() -> void:

	#active_soldier = false
	x=king.position.x-16
	y=king.position.y-16
	if setup_done == false:
		spawn_soldiers()
		spawn_coins(coins_number)
		setup_done = true
	pass
	

func _physics_process(delta: float) -> void:
	#print(currently_moving)
	
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
	var coins = []
	while i < coins_numb:
		var coin = coin_scene.instantiate()
		x = round(randf_range(0, 10))
		y = round(randf_range(0, 10))
		print(x," ", y)
		if x > 2 and y > 2 and x < 8 and y < 8:
			pass
		else:
			x = king.position.x-(5*16) + x*16
			y = king.position.y+(5*16) - y*16
			var pos = [x, y]
			#print(pos)
			if pos not in coins:
				i += 1
			else:
				print("Double")
			coin.position = Vector2(x, y)
			coins.append([x, y])
			if i == coins_numb+1:
				print("Array: ",coins)
			add_child(coin)

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
