extends Node2D
var difficulty = 0
#run metrics:
var wins = 0
var losses = 0

func difficulty_name() -> String:
	match difficulty:
		0: return "Baby Mode"
		1: return "Still Easy"
		2: return "Normie"
		3: return "Keyboard Smasher"
		4: return "Rage Quit"
		5: return "Masochist"
	return "God Mode"
