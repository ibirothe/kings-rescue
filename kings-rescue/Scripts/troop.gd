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
var j = 0
var x = 0  # Initialize x
var y = 0  # Initialize y
var setup_done = false
@onready var game_manager = get_parent()
var soldiers = []
@export var soldier_scene: PackedScene
var move_dir: Vector2

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
			game_manager.informantion.append(subclass+ " is an assassin.")
		elif role == "Mercenary":
			soldier.mercenary = true
			soldier.role = "Soldier"
		else:
			soldier.role = "Soldier"
		roles.erase(role)
		
		
		match i:
			0:
				x -= 16
				y -= 16
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
		self.add_child(soldier)
		soldiers.append(soldier)

func _physics_process(_delta: float) -> void:
	if soldier_can_move():

		match movement_direction:
			"up": move_dir = Vector2(0, -16)
			"down": move_dir = Vector2(0, 16)
			"left": move_dir = Vector2(-16, 0)
			"right": move_dir = Vector2(16,0)
		current_soldier.movestart_position = current_soldier.position
		current_soldier.move_character(move_dir)
		reset_clicks()
	elif soldier_can_change():
		activate_soldier(activating_soldier)
		deactivate_soldier(current_soldier)
		current_soldier = activating_soldier
		print("Changing soldier")
		reset_clicks()
	elif soldier_can_activate():
		print("First activation")
		activate_soldier(activating_soldier)
		current_soldier = activating_soldier
		reset_clicks()


func movement_query(where, guy):
	movement_click = true
	movement_direction = where
	moving_soldier = guy
	click_resolved = false

func activation_query(guy):
	activation_click = true
	activating_soldier = guy
	click_resolved = false
	
func activate_soldier(soldier) -> void:
	soldier.active = true
	AudioManager.play_sound("select_soldier")
	soldier.animated_sprite_2d.play(soldier.subclass+"_idle")
	soldier.transition_to_state(soldier.State.IDLE)
	soldier.visual_activation()
	GlobalText.set_text(game_manager.txt.CHARACTER_DESCRIPTIONS[soldier.subclass])
	
func deactivate_soldier(soldier) -> void:
	soldier.animated_sprite_2d.play(soldier.subclass+"_default")
	soldier.transition_to_state(soldier.State.INACTIVE)
	soldier.visual_deactivation()
	soldier.active = false
	
func reset_clicks():
	click_resolved = true
	activation_click = false
	movement_click = false
	moving_soldier = []
	movement_direction = []
	j = 0

# Condition checks
func soldier_can_move() -> bool:
	return movement_click and !activation_click and !click_resolved and current_soldier != null
	
func soldier_can_change() -> bool:
	return activation_click and current_soldier != null and !click_resolved
	
func soldier_can_activate() -> bool:
	return activation_click and !click_resolved
