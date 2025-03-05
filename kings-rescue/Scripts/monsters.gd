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
var j = 0
var x = 0  # Initialize x
var y = 0  # Initialize y
var setup_done = false
@onready var game_manager = get_parent()
var soldiers = []
var move_dir: Vector2
var direct
@onready var king: CharacterBody2D = $King
var doggo_directions = []
var buddy
var monsters = []
var canine_numb


func spawn_doggos(canine_numb):
	var i = 0
	while i < canine_numb + 2 * RunStats.difficulty:
		var doggo = dog_scene.instantiate()
		x = round(randf_range(0, 10))
		y = round(randf_range(0, 10))
		"""
		if x > 2 and y > 2 and x < 8 and y < 8:
			pass
		else:
			x = king.position.x-(5*16) + x*16
			y = king.position.y+(5*16) - y*16
			var pos = Vector2(x, y)
			
			if pos not in game_manager.occupied_positions:"""
		match i:
			0:
				x -= 48
				y -= 48
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
		var pos = Vector2(x,y)
		if true:
			i += 1
			doggo.position = pos
			game_manager.occupied_positions.append(pos)
			add_child(doggo)
			doggo.number = i-1
			if x > 0:
				direct = Vector2(-16, 0)
			else:
				direct = Vector2(16, 0)
			doggo_directions.append(direct)
			monsters.append(doggo)
			print(doggo_directions)

func _physics_process(_delta: float) -> void:
	pass
	
func move_all():
	for buddy in monsters:
		buddy.move(buddy)
		
func _get_direction(monster, number):
	if monster == "dog":
		return doggo_directions[number]
