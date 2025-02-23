extends CharacterBody2D
enum State {INACTIVE, IDLE, MOVING}
var role = "King"
@onready var up: Area2D = $Up
@onready var down: Area2D = $Down
@onready var left: Area2D = $Left
@onready var right: Area2D = $Right
var direction_check = false
@onready var center: Marker2D = $Center
@onready var king_shape: CollisionShape2D = $King_shape
@onready var game_manager: Node2D = $"../Game Manager"
var right_legal
var current_state
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var tween
const MOVE_TIME := 0.5  # Time in seconds to complete movement
@onready var win: Area2D = $Win
var trap = false

func _ready() -> void:
	#print(position)
	pass
	
func _physics_process(_delta: float) -> void:
	#print(direction_check)
	if game_manager.party_ended and len(win.get_overlapping_bodies()) == 0 or trap == true:
		if animated_sprite_2d.animation != "death":
			animated_sprite_2d.play("death")
			AudioManager.play_sound("player_death")
		return
	if game_manager.currently_moving == true:
		king_shape.disabled = true
	else:
		king_shape.disabled = false

	match current_state:
		State.IDLE:
			handle_idle_state()
		State.MOVING:
			# Movement is handled by tween, we just watch for new input
			pass
	if len(win.get_overlapping_bodies()) > 0:
		game_manager.party_ended = true
		win_anim()
		GlobalText.set_text("The King hath fled, the traitors dangle, and order is restored. Dost thou sleep soundly now, oh righteous one?")
			
func king():
	direction_check = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	#if direction_check == false:
		var direction = center.global_position.direction_to(body.center.global_position)
		print(direction/3.14*180)
		if direction.x < 0 and direction.y == 0:
			print("right")
			if len(right.get_overlapping_bodies()) > 0:
				body.turn_back()
				print(right.get_overlapping_bodies())
				print("illegal")
			else:
				move_character(body.movement)
		if direction.x > 0 and direction.y == 0:
			print("left")
			if len(left.get_overlapping_bodies()) > 0:
				body.turn_back()
				print("illegal")
			else:
				move_character(body.movement)
		if direction.x == 0 and direction.y > 0:
			print("up")
			if len(up.get_overlapping_bodies()) > 0:
				body.turn_back()
				print("illegal")
			else:
				move_character(body.movement)
		if direction.x == 0 and direction.y < 0:
			print("down")
			if len(down.get_overlapping_bodies()) > 0:
				body.turn_back()
				print("illegal")
			else:
				move_character(body.movement)
		#direction_check = true
	
func handle_idle_state() -> void:
	pass
			
func move_character(movement: Vector2) -> void:
		
	#print(get_parent().soldier_in_a_way, im_new)
	if current_state == State.MOVING:
		return
	transition_to_state(State.MOVING)
	animated_sprite_2d.play("walk")

	tween = create_tween()
	tween.tween_property(self, "position", 
		position + movement, MOVE_TIME
	).set_trans(Tween.TRANS_LINEAR)
	
	# When movement completes
	tween.tween_callback(func():
		animated_sprite_2d.play("idle")
		transition_to_state(State.IDLE)
		)
func transition_to_state(new_state: State) -> void:
	match new_state:
		State.INACTIVE:
			animated_sprite_2d.play("default")
		State.IDLE:
			animated_sprite_2d.play("idle")
	
	current_state = new_state

func win_anim():
	animated_sprite_2d.play("walk")
	var tween = create_tween()
	
	# Fade out over 1 second
	tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()  # Remove the node after fading out
