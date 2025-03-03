extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager = get_parent()
@onready var shop: Node2D = get_parent().get_node("Shop")

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Soldier:
		GlobalText.set_text(game_manager.txt.ingame["shop_collect"].pick_random())
		AudioManager.play_sound("shop_collect")
		
		var max_attempts = 100  # Prevent infinite loop
		var attempts = 0
		var item = null
		var found = false
		
		while !found and attempts < max_attempts:
			var keys = shop.item_list.keys()
			item = keys[randi() % keys.size()]
			
			# Check if item is unique
			if !shop.item_list[item][1]:
				found = true
			elif !GlobalDifficulty.upgrade_items.has(item) and !GlobalDifficulty.shop_items.has(item):
				found = true
			
			attempts += 1
		
		if found:
			GlobalDifficulty.shop_items.append(item)
			
			# Delete the item
			var tween = create_tween()
			tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
			await tween.finished
			queue_free()  # Remove the node after fading out
		else:
			print("Could not find a suitable item after", max_attempts, "attempts")
