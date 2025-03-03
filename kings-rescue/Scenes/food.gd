extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var game_manager: Node2D = get_parent()
@export var food_efficiency = 8

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Soldier:
		GlobalText.set_text(game_manager.txt.ingame["food"].pick_random())
		game_manager.food += food_efficiency-RunStats.difficulty
		AudioManager.play_sound("food_collect")
		# Delete the item
		var tween = create_tween()
		tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
		await tween.finished
		queue_free()  # Remove the node after fading out
