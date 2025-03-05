extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var game_manager: Node2D = get_parent()

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Soldier:
		GlobalText.set_text(game_manager.txt.ingame["door"].pick_random())
		game_manager.troop.soldiers.erase(body)
		var soldier_tween = create_tween()
		body.disable_shader()
		# Fade out over 1 second
		soldier_tween.tween_property(body.animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
		await soldier_tween.finished
		body.queue_free()  # Remove the node after fading out
		animated_sprite_2d.play("Activate")
		AudioManager.play_sound("door_activate")
		await get_tree().create_timer(0.8).timeout
		RunStats.increase_difficulty()
		RunStats.upgrade_items.erase("Dimensional Key")
		# Delete the item
		var tween = create_tween()
		tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
		await tween.finished
		queue_free()  # Remove the node after fading out
