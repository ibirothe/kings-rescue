extends Node2D

@onready var label0 = $Shop_0_label
@onready var label1 = $Shop_1_label
@onready var label2 = $Shop_2_label
var labels = []

@onready var prize0 = $Shop_0_prize
@onready var prize1 = $Shop_1_prize
@onready var prize2 = $Shop_2_prize
var prizes = []

@onready var buy0 = $Shop_0_buy
@onready var buy1 = $Shop_1_buy
@onready var buy2 = $Shop_2_buy
var buy_buttons = []

@onready var info0 = $Shop_0_info
@onready var info1 = $Shop_1_info
@onready var info2 = $Shop_2_info
var info_buttons = []

var item_list = {
	"Pay Mercenaries": [10, true],
	"Trap Specialists": [20, true],
	"Food Ration": [8, false],
	"Hourglass": [12, true],
	"Life Insurance": [10, true],
	"Dimensional Key": [1, true],
	"Trained Chef": [8, true],
	"Mimic Tranquilizer": [3, true]
}

func _ready() -> void:
	labels = [label0, label1, label2]
	buy_buttons = [buy0, buy1, buy2]
	info_buttons = [info0, info1, info2]
	prizes = [prize0, prize1, prize2]

func _process(delta: float) -> void:
	for i in range(3):
		if i >= RunStats.shop_items.size():
			labels[i].text = ""
			prizes[i].text = ""
			buy_buttons[i].visible = false
			info_buttons[i].visible = false
		else:
			var item_name = RunStats.shop_items[i]
			var price = item_list.get(item_name, "???")[0]
			prizes[i].text = str(price) + " Gold"
			labels[i].text = item_name
			buy_buttons[i].visible = true
			info_buttons[i].visible = true
