extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func press
	if Input.is_action_just_pressed("Magic"):
		magic_pressed = true
		
