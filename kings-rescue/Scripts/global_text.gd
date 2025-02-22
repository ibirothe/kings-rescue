extends Node

signal text_changed(new_text: String)
var current_text: String = ""

func set_text(new_text: String) -> void:
	current_text = new_text
	text_changed.emit(current_text)

func get_text() -> String:
	return current_text
