extends CharacterBody2D

class_name Soldier
enum State {INACTIVE, IDLE, MOVING}

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var current_state: State = State.INACTIVE  # Start as INACTIVE
const MOVE_DISTANCE := 16.0
const MOVE_TIME := 0.5  # Time in seconds to complete movement
const INTERACTION_RADIUS := 25.0
var target_position := Vector2.ZERO
var assassin = false
var possible_assassination = false
var soldier_close = false
var number = 0
var subclass
var click_resolved = false
var im_new = true
var active = false
var next_cycle = false
var cycle_sync = false
var movement_locked = false
var movement = Vector2.ZERO

func _ready() -> void:
	# Start with default animation
	animated_sprite_2d.play("default")
	match subclass:
		"brute":
			assassin = true
	
	

func _physics_process(_delta: float) -> void:
	if active ==true:
		#print(im_new)
		pass
	match current_state:
		State.INACTIVE:
			handle_inactive_state()
		State.IDLE:
			handle_idle_state()
		State.MOVING:
			# Movement is handled by tween, we just watch for new input
			handle_movement_input()
	if click_resolved == true:
		click_resolved == false

func handle_inactive_state() -> void:
	pass
	#Changed to activation_area area2d
	"""if Input.is_action_just_pressed("left_click"):
		var click_pos = get_global_mouse_position()
		# Check if click is on or very close to the character
		if position.distance_to(click_pos) < INTERACTION_RADIUS:
			AudioManager.play_sound("select_soldier")
			transition_to_state(State.IDLE)"""

func handle_idle_state() -> void:
	 #, #GameManager.soldier_changing
	if get_parent().soldier_changing == true and im_new == false:
		transition_to_state(State.INACTIVE)
	if get_parent().soldier_changing == false and im_new == true:
		im_new = false
		active = true
	if Input.is_action_just_pressed("left_click") and get_parent().click_resolved == false:
		var click_pos = get_global_mouse_position()
		# If clicked far from character, return to inactive
		if position.distance_to(click_pos) > INTERACTION_RADIUS:
			AudioManager.play_sound("disselect_soldier")
			GlobalText.set_text("You changed to Not Active.")
			#print("Becoming inactive")
			transition_to_state(State.INACTIVE)
			if get_parent().soldier_changing == false:
				get_parent().active_soldier = false
			active = false
		else:
			handle_movement_input()


func handle_movement_input() -> void:
	match current_state:
		State.INACTIVE:
			return
	if not Input.is_action_just_pressed("left_click"):
		return
	var click_pos = get_global_mouse_position()

	# Check if click is outside interaction range
	if position.distance_to(click_pos) > INTERACTION_RADIUS:
		#print("Becoming inactive")
		transition_to_state(State.INACTIVE)
		if get_parent().soldier_changing == false:
			get_parent().active_soldier = false
			im_new = true
			active = false
		return
	if get_parent().soldier_in_a_way == true and im_new == false:
		#print("Guy in a way")
		transition_to_state(State.INACTIVE)
		return
	if get_parent().soldier_changing == true and im_new == false:
		transition_to_state(State.INACTIVE)
		im_new = true
		active = false
		return
	if movement_locked == false and active == true: 
		movement = calculate_grid_movement(click_pos)
		get_parent().currently_moving = true
		movement_locked = true

	if movement != Vector2.ZERO:
		# Update sprite flip based on movement direction
		if movement.x != 0:
			animated_sprite_2d.flip_h = movement.x < 0
	if active == true:
		move_character(movement)



func calculate_grid_movement(click_pos: Vector2) -> Vector2:
	var diff = click_pos - position
	
	# Check for cardinal directions within 16-pixel grid
	if abs(diff.x) > 8 and abs(diff.x) < 24 and abs(diff.y) < 8:
		return Vector2(sign(diff.x) * MOVE_DISTANCE, 0)
	elif abs(diff.y) > 8 and abs(diff.y) < 24 and abs(diff.x) < 8:
		return Vector2(0, sign(diff.y) * MOVE_DISTANCE)
	
	return Vector2.ZERO

func move_character(movement: Vector2) -> void:
	
	#print(get_parent().soldier_in_a_way, im_new)
	if current_state == State.MOVING:
		return
	transition_to_state(State.MOVING)
	animated_sprite_2d.play("walk")
	GlobalText.set_text("You started Moving.")
	var tween = create_tween()
	tween.tween_property(self, "position", 
		position + movement, MOVE_TIME
	).set_trans(Tween.TRANS_LINEAR)
	
	# When movement completes
	tween.tween_callback(func():
		animated_sprite_2d.play("idle")
		transition_to_state(State.IDLE)
		get_parent().movement_resolved(possible_assassination, soldier_close)
		movement_locked = false
		get_parent().currently_moving = false
		)
	

func transition_to_state(new_state: State) -> void:
	match new_state:
		State.INACTIVE:
			animated_sprite_2d.play("default")
			active = false
			im_new = true
		State.IDLE:
			animated_sprite_2d.play("idle")
	
	current_state = new_state


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		if get_parent().active_soldier == false and get_parent().click_resolved == false and get_parent().currently_moving == false:
			get_parent().active_soldier = true
			get_parent().click_resolved = true
			im_new = false
			active = true
			#print("soldier activated", click_resolved)
		if get_parent().active_soldier == true and get_parent().click_resolved == false and get_parent().currently_moving == false:
			get_parent().soldier_in_a_way = true
			get_parent().soldier_changing = true
			get_parent().click_resolved = true
			#print("changing soldier")
		if get_parent().currently_moving == false:
			AudioManager.play_sound("select_soldier")
			transition_to_state(State.IDLE)


func _on_neighbours_check_body_entered(body: Node2D) -> void:
	if body.has_node("King"):
		if assassin == true:
			possible_assassination = true
	if body.has_node("Soldier"):
		if assassin == true:
			soldier_close = true
