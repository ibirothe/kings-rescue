extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var game_manager: Node2D = get_parent()
@export var food_efficiency = 10
var mercenary
func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.mercenary == true:
		#body.active = false
		body.animated_sprite_2d.play(body.subclass+"_default")
		body.stop()
		body.active = false
		body.animated_sprite_2d.play(body.subclass+"_walk")
		body.get_parent().active_soldier = false
		body.get_parent().click_resolved = false
		body.get_parent().currently_moving = false
		body.take_coin()
		AudioManager.play_sound("mercenary_flee")
		GlobalText.set_text("A mercenary fled. They value gold higher than loyalty, but even the best King’s Guard has two of them.")
		var tween = create_tween()
	
	# Fade out over 1 second
		tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
		await tween.finished
		queue_free()  # Remove the node after fading out
