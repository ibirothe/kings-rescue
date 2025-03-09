extends Button

@onready var shop = get_parent()
@onready var game_manager = get_parent().get_parent()

@export var shop_index: int

func _ready():
	button_down.connect(_on_button_down)

func _on_button_down():
	if RunStats.shop_items.size() <= shop_index:
		return
	elif RunStats.coins < shop.item_list[RunStats.shop_items[shop_index]][0]:
		GlobalText.set_text(game_manager.txt.shop["no_money"].pick_random())
	else:
		GlobalText.set_text(game_manager.txt.shop["bought"].pick_random())
		AudioManager.play_sound("buy")
		
		RunStats.spend_coins(shop.item_list[RunStats.shop_items[shop_index]][0])
		if RunStats.shop_items[shop_index] == "Food Ration":
			game_manager.food += 10
		else:
			RunStats.upgrade_items.append(RunStats.shop_items[shop_index])
		RunStats.shop_items.pop_at(shop_index)
