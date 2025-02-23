extends Area2D

@onready var game_manager: Node2D = get_parent()
@export var food_efficiency = 10

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.mercenary == true:
		#body.active = false
		body.animated_sprite_2d.play(body.subclass+"_default")
		body.stop()
		body.active = false
		body.get_parent().active_soldier = false
		body.get_parent().click_resolved = false
		body.get_parent().currently_moving = false
		body.queue_free()
		AudioManager.play_sound("mercenary_flee")
		# Delete the item
		GlobalText.set_text("A mercenary fled. They value gold higher than loyalty, but even the best King’s Guard has two of them.")
		queue_free()
		
