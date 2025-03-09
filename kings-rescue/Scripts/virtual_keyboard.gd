extends Control

@onready var button1 = $"Button1"
@onready var button2 = $"Button2"

func _ready() -> void:
	if RunStats.stored_loss:
		button1.text = "Start New Game"
		button1.action_name = "Delete"
		button2.text = "Return to Menu"
		
	else:
		button1.text = "Continue"
		button1.action_name = "Restart"
		button2.text = "Save and Quit"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
