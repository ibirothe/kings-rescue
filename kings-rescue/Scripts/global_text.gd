extends Node

signal text_changed(new_text: String, new_char: String)
var current_text: String = ""
var current_char: String = ""

func set_text(new_text: String, new_char: String = "") -> void:
	current_text = new_text
	if new_char != "":
		current_char = new_char
	text_changed.emit(current_text, current_char)

func get_text() -> String:
	return current_text

func get_char() -> String:
	return current_char
