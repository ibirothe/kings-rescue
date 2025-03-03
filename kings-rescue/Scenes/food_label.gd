extends Label

func _process(delta: float) -> void:
	text = str(GlobalDifficulty.coins)
