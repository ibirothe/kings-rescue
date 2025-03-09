extends Label

@onready var game_manager: Node2D = $"../Game Manager"

func _process(delta: float) -> void:
	text = str(game_manager.food)

func spawn_floating_number(value: int) -> void:
	# Create a new Label instance
	var floating_label = Label.new()
	var duration: float = 0.8
	
	floating_label.text = "+" + str(value)
	floating_label.modulate = Color(1, 1, 1, 1)
	floating_label.position = Vector2(global_position.x, global_position.y - 5)
	floating_label.scale = Vector2(0.5, 0.5) # Scale to 50%
	
	# Copy the parent's LabelSettings
	if label_settings:
		floating_label.label_settings = label_settings
	get_parent().add_child(floating_label)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(floating_label, "position:y", floating_label.position.y - 10, duration)
	tween.tween_property(floating_label, "modulate:a", 0, duration)
	await tween.finished
	floating_label.queue_free()
