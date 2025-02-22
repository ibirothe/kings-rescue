extends Node2D
var rng = RandomNumberGenerator.new()
var subclasses = ["Rupert", "Thoralf", "Ogra", "Bartholo", "Ibrahim", "Edwin", "Marquise", "Arianna"]
var x = 0  # Initialize x
var y = 0  # Initialize y
var setup_done = false
@export var soldier: PackedScene


func _ready() -> void:
	spawn_soldiers()

func spawn_soldiers():
	for i in range(8):
		var inst = soldier.instantiate()
		var j = round(randf_range(0, len(subclasses)-1))
		print(j)
		inst.subclass = subclasses[j]
		
		match i:
			0:
				x = -8
				y = 9
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
		
		inst.position = Vector2(x, y)
		Level.add_child(inst)
