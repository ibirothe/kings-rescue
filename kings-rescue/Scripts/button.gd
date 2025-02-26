extends Button
# The input action this button should trigger
@export var action_name: String

func _ready():
	# Connect the button_down and button_up signals
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	
func _on_button_down():
	# Simulate the input action being pressed
	Input.action_press(action_name)

func _on_button_up():
	# Simulate the input action being released
	Input.action_release(action_name)
