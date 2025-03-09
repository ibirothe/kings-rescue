extends Area2D  # Or your node type

@export var help_key: String
@onready var game_manager = $"../../Game Manager"
var mouse_inside = false

func _ready():
	# You need an Area2D for this approach
	var area = self
	if area != null:
		area.connect("mouse_entered", _on_mouse_entered)
		area.connect("mouse_exited", _on_mouse_exited)

func _on_mouse_entered():
	mouse_inside = true

func _on_mouse_exited():
	mouse_inside = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and mouse_inside:
			GlobalText.set_text(game_manager.txt.help[help_key])
			get_viewport().set_input_as_handled()
