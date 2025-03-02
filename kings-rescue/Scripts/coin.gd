extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node2D = get_parent()

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	pass
	if body.mercenary and !body.paid:
		body.animated_sprite_2d.play(body.subclass+"_default")
		body.stop_movement()
		body.active = false
		body.animated_sprite_2d.play(body.subclass+"_walk")
		game_manager.active_soldier = false
		game_manager.currently_moving = false
		body.take_coin()
		AudioManager.play_sound("mercenary_flee")
		GlobalText.set_text(game_manager.txt.ingame["mercenary_flee"].pick_random())
	elif body.mercenary and body.paid:
		GlobalDifficulty.coins += 1
		AudioManager.play_sound("coin_collect")
		GlobalText.set_text(game_manager.txt.ingame["mercenary_not_flee"].pick_random())
	else :
		GlobalDifficulty.coins += 1
		AudioManager.play_sound("coin_collect")
		
	# Fade out over 1 second
	var tween = create_tween()
	tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()
		
