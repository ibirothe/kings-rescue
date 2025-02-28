extends Label

@onready var game_manager: Node2D = $"../Game Manager"

func _process(delta: float) -> void:
	text = str(game_manager.food)
