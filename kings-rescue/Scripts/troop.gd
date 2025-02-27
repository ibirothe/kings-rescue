extends Node2D
var subclasses = ["Rupert", "Thoralf", "Ogra", "Bartholo", "Ibrahim", "Edwin", "Marquise", "Arianna"]
var roles = ["Mercenary", "Mercenary", "Assassin", "Assassin", "Soldier", "Soldier", "Soldier", "Soldier"]
var movement_click = false
var movement_direction = []
var moving_soldier = []
var activating_soldier
var soldier
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
var move_dir

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
		self.add_child(soldier)
		soldiers.append(soldier)

# Activate target soldier and deactivate everyone else
"""func activate_soldier(target_soldier) -> void:
	for soldier in soldiers:
		if !soldier.dead:
			if soldier == target_soldier:
				soldier.active = true
				AudioManager.play_sound("select_soldier")
				soldier.animated_sprite_2d.play(soldier.subclass+"_idle")
				soldier.transition_to_state(soldier.State.IDLE)
				soldier.visual_activation()
				GlobalText.set_text(soldier.CHARACTER_DESCRIPTIONS[soldier.subclass], soldier.subclass)
			else:
				soldier.animated_sprite_2d.play(soldier.subclass+"_default")
				soldier.transition_to_state(soldier.State.INACTIVE)
				soldier.visual_deactivation()
				soldier.active = false"""

func _physics_process(_delta: float) -> void:
	if movement_click == true and activation_click == false and click_resolved == false and current_soldier != null:
		for i in moving_soldier:
			if current_soldier == i:
				match movement_direction[j]:
					"up": move_dir= Vector2(0, -16)
					"down": move_dir = Vector2(0, 16)
					"left": move_dir = Vector2(-16, 0)
					"right": move_dir = Vector2(16,0)
				current_soldier.movestart_position = current_soldier.position
				print(current_soldier.movestart_position)
				current_soldier.move_character(move_dir)
			j += 1
		reset_clicks()
	elif movement_click == true and activation_click == true and click_resolved == false and current_soldier != null:
		deactivate_soldier(current_soldier)
		activate_soldier(activating_soldier)
		current_soldier = activating_soldier
		reset_clicks()
		print("Reactivation")
	elif activation_click == true and current_soldier != null:
		activate_soldier(activating_soldier)
		deactivate_soldier(current_soldier)
		current_soldier = activating_soldier
		print("Changing soldier")
		reset_clicks()
	elif activation_click == true and click_resolved == false:
		print("First activation")
		activate_soldier(activating_soldier)
		current_soldier = activating_soldier
		reset_clicks()


func movement_query(where, guy):
	movement_click = true
	movement_direction.append(where)
	moving_soldier.append(guy)
	click_resolved = false

func activation_query(guy):
	activation_click = true
	activating_soldier = guy
	click_resolved = false
	
func activate_soldier(target_soldier) -> void:
	soldier = target_soldier
	soldier.active = true
	AudioManager.play_sound("select_soldier")
	soldier.animated_sprite_2d.play(soldier.subclass+"_idle")
	soldier.transition_to_state(soldier.State.IDLE)
	soldier.visual_activation()
	GlobalText.set_text(soldier.CHARACTER_DESCRIPTIONS[soldier.subclass], soldier.subclass)
	
func deactivate_soldier(target_soldier) -> void:
	soldier = target_soldier
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
