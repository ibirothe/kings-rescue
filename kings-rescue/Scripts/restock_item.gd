extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager = get_parent()
@onready var shop: Node2D = get_parent().get_node("Shop")
var mimic = false

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Soldier:
		AudioManager.play_sound("shop_collect")
		
		var max_attempts = 100  # Prevent infinite loop
		var attempts = 0
		var item = null
		var found = false
		print(mimic)
		print(RunStats.upgrade_items.has("Mimic Tranquilizer"))
		if not mimic:
			while !found and attempts < max_attempts:
				var keys = shop.item_list.keys()
				item = keys[randi() % keys.size()]
				
				# Check if item is unique
				if !shop.item_list[item][1]:
					found = true
				elif !RunStats.upgrade_items.has(item) and !RunStats.shop_items.has(item):
					found = true
				
				attempts += 1
			
			if found:
				RunStats.add_shop_item(item)
				GlobalText.set_text(game_manager.txt.ingame["shop_collect"].pick_random())
		elif mimic and RunStats.upgrade_items.has("Mimic Tranquilizer"):
			RunStats.upgrade_items.erase("Mimic Tranquilizer")
			GlobalText.set_text(game_manager.txt.ingame["mimic_tranquilized"].pick_random())
			game_manager.add_coin(10)
			game_manager.add_food(5)
			
			while !found and attempts < max_attempts:
				var keys = shop.item_list.keys()
				item = keys[randi() % keys.size()]
				
				# Check if item is unique
				if !shop.item_list[item][1]:
					found = true
				elif !RunStats.upgrade_items.has(item) and !RunStats.shop_items.has(item):
					found = true
				
				attempts += 1
			
			if found:
				RunStats.add_shop_item(item)
			
		elif mimic:
			RunStats.shop_items = []
			GlobalText.set_text(game_manager.txt.ingame["mimic_collect"].pick_random())
			
		# Delete the item
		var tween = create_tween()
		tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
		await tween.finished
		queue_free()  # Remove the node after fading out
