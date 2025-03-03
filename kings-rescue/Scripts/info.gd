extends Button

@onready var shop = get_parent()
@onready var game_manager = get_parent().get_parent()

@export var shop_index: int

func _ready():
	button_down.connect(_on_button_down)

func _on_button_down():
	if GlobalDifficulty.shop_items.size() <= shop_index:
		return
	else:
		GlobalText.set_text(game_manager.txt.shop[GlobalDifficulty.shop_items[shop_index]])
