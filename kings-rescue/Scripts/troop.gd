extends Node2D
var subclasses = ["Rupert", "Thoralf", "Ogra", "Bartholo", "Ibrahim", "Edwin", "Marquise", "Arianna"]
var roles = ["Mercenary", "Mercenary", "Assassin", "Assassin", "Soldier", "Soldier", "Soldier", "Soldier"]

var x = 0  # Initialize x
var y = 0  # Initialize y
var setup_done = false
@onready var game_manager = get_parent()
var soldiers = []
@export var soldier_scene: PackedScene

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
func activate_soldier(target_soldier) -> void:
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
				soldier.active = false
