extends Button

@onready var shop = get_parent()
@onready var game_manager = get_parent().get_parent()

@export var shop_index: int

func _ready():
	button_down.connect(_on_button_down)

func _on_button_down():
	if GlobalDifficulty.shop_items.size() <= shop_index:
		return
	elif GlobalDifficulty.coins < shop.item_list[GlobalDifficulty.shop_items[shop_index]][0]:
		GlobalText.set_text(game_manager.txt.shop["no_money"].pick_random())
	else:
		GlobalDifficulty.coins -= shop.item_list[GlobalDifficulty.shop_items[shop_index]][0]
		if GlobalDifficulty.shop_items[shop_index] == "Food Ration":
			game_manager.food += 10
		else:
			GlobalDifficulty.upgrade_items.append(GlobalDifficulty.shop_items[shop_index])
		GlobalDifficulty.shop_items.pop_at(shop_index)
