extends Node

signal text_changed(new_text: String, new_char: String)
var current_text: String = ""

func set_text(new_text: String) -> void:
	current_text = new_text
	# Emit the signal so connected objects (like your Label) can respond
	text_changed.emit(new_text)

func add_text(addition: String) -> void:
	var new_text = current_text + addition
	current_text = new_text
	# Emit the signal so connected objects (like your Label) can respond
	text_changed.emit(new_text)

func get_text() -> String:
	return current_text
