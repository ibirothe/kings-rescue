extends Area2D

@onready var game_manager: Node2D = get_parent()
@export var food_efficiency = 10
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var number
var info


func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)
	animated_sprite_2d.play("default")

func _on_body_entered(body):
	if body is Soldier:
		#body.active = false
		if body.assassin == true:
			var i = round(randf_range(0, 9))
			GlobalText.set_text(game_manager.txt.assassin_manuals[i])
		#elif body.mercenary == true:
		#	var i = round(randf_range(0, 4))
		#	GlobalText.set_text(game_manager.txt.mercenary_manuals[i])
		else:
			GlobalText.set_text(str(info))
		# Delete the item
		var tween = create_tween()
		tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
		await tween.finished
		queue_free()  # Remove the node after fading out
