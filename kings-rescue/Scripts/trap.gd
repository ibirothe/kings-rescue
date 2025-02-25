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
		GlobalText.set_text("A hidden trap killed a Soldier of the King’s Guard. Well, technically, it was you.")
		body.death()
		body.z_index = 0
		AudioManager.play_sound("player_hurt")
		# Delete the item
	if body.has_method("king"):
		#body.active = false
		animated_sprite_2d.play("trigger")
		body.trap = true
		AudioManager.play_sound("")
		if game_manager.party_ended == false:
			GlobalDifficulty.losses +=1
			var lose_text = "You managed to stop the Assassins from killing the King... by doing it yourself. \n \nWINS: " + str(GlobalDifficulty.wins) + "\n \nLOSSES: " + str(GlobalDifficulty.losses) + "\n \nDIFFICULTY: " + str(GlobalDifficulty.difficulty_name()) + "\n \nHistory keeps repeating itself-maybe next time, you won’t be the one to slay the King. Press 'R' to retry... and perhaps find a safer path!"
			GlobalText.set_text(lose_text)
			game_manager.win_fade_out()
			game_manager.party_ended = true
