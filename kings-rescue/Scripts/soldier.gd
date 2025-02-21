extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed = 200
var click_position = Vector2()
var target_position = Vector2()
var active = false
var activation_click = true
var x_dist
var y_dist
var click_resolved = true

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		click_position = get_global_mouse_position()
		x_dist = click_position.x-position.x
		y_dist = click_position.y-position.y
		#print(x_dist," ",y_dist)
		click_resolved = false
	if position.distance_to(click_position)<15 and active==false:
		animated_sprite_2d.play("active")
		active = true
		activation_click = true
		click_resolved = true
	if active == true and click_resolved == false:
		#right
		if x_dist > 8 and x_dist < 24 and y_dist > -8 and y_dist < 8:
			print("right")
			for i in range(16):
				position.x +=1
		#left
		elif x_dist > -24 and x_dist < -8 and y_dist > -8 and y_dist < 8:
			print("left")
			for i in range(16):
				position.x -=1
		#up
		elif y_dist > 8 and y_dist < 24 and x_dist > -8 and x_dist < 8:
			print("down")
			for i in range(16):
				position.y +=1
		#down
		elif y_dist > -24 and y_dist < -8 and x_dist > -8 and x_dist < 8:
			print("up")
			for i in range(16):
				position.y -=1
		else:
			animated_sprite_2d.play("default")
			active = false
		click_resolved = true
