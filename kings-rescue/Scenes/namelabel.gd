extends Label

@onready var type_timer

var target_char: String = ""
var current_display_length: int = 0
var typing_speed: float = 0.01
var characters_per_tick: int = 2

@export var custom_typing_speed: float = 0.01
@export var custom_chars_per_tick: int = 2

func _ready():
	if !has_node("TypeTimer"):
		var timer = Timer.new()
		timer.name = "TypeTimer"
		add_child(timer)
		type_timer = timer
	
	typing_speed = custom_typing_speed
	characters_per_tick = custom_chars_per_tick
	
	GlobalText.text_changed.connect(_on_text_changed)
	type_timer.timeout.connect(_on_type_timer_timeout)
	type_timer.one_shot = false
	type_timer.wait_time = typing_speed

func _on_text_changed(new_text: String, new_char: String) -> void:
	# Skip if the new text is the same as current target text
	if new_char == target_char:
		return
		
	target_char = new_char
	current_display_length = 0
	text = ""
	type_timer.start()

func _on_type_timer_timeout() -> void:
	if current_display_length < target_char.length():
		current_display_length += characters_per_tick
		text = target_char.substr(0, current_display_length)
	else:
		type_timer.stop()
