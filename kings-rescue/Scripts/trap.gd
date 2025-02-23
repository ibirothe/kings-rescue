extends Area2D

@onready var game_manager: Node2D = get_parent()
@export var food_efficiency = 10
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)
	animated_sprite_2d.play("default")

func _on_body_entered(body):
	if body is Soldier:
		#body.active = false
		animated_sprite_2d.play("trigger")
		body.animated_sprite_2d.play(body.subclass+"_death")
		GlobalText.set_text("A hidden trap killed a Soldier of the King’s Guard. Or actually, it was you.")
		body.death()
		AudioManager.play_sound("player_hurt")
		# Delete the item
	if body.has_method("king"):
		#body.active = false
		animated_sprite_2d.play("trigger")
		body.trap = true
		AudioManager.play_sound("")
		GlobalText.set_text("You managed to stop the Assassins from killing the King. You just did it yourself.")
