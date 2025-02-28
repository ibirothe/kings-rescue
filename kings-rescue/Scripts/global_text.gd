extends Node

signal text_changed(new_text: String, new_char: String)
var current_text: String = ""

func set_text(new_text: String, new_char: String = "") -> void:
	current_text = new_text

func get_text() -> String:
	return current_text
