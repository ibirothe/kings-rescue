extends Area2D

@onready var game_manager: Node2D = get_parent()
@export var food_efficiency = 10

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Soldier:
		#body.active = false
		body.animated_sprite_2d.play(body.subclass+"_default")
		GlobalText.set_text("You gathered some Food. Running out of supplies leads to starvation, so this was a wise choice. If only it weren’t an apple...", "Apple")
		game_manager.food += food_efficiency
		AudioManager.play_sound("food_collect")
		# Delete the item
		queue_free()
