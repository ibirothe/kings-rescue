extends Label

func _process(delta: float) -> void:
	text = str(RunStats.coins)
