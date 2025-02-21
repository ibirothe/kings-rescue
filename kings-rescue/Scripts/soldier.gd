extends CharacterBody2D

enum State {INACTIVE, IDLE, MOVING}

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var current_state: State = State.INACTIVE  # Start as INACTIVE
const MOVE_DISTANCE := 16.0
const MOVE_TIME := 0.5  # Time in seconds to complete movement
const INTERACTION_RADIUS := 25.0
var target_position := Vector2.ZERO

func _ready() -> void:
	# Start with default animation
	animated_sprite_2d.play("default")

func _physics_process(_delta: float) -> void:
	match current_state:
		State.INACTIVE:
			handle_inactive_state()
		State.IDLE:
			handle_idle_state()
		State.MOVING:
			# Movement is handled by tween, we just watch for new input
			handle_movement_input()

func handle_inactive_state() -> void:
	if Input.is_action_just_pressed("left_click"):
		var click_pos = get_global_mouse_position()
		# Check if click is on or very close to the character
		if position.distance_to(click_pos) < INTERACTION_RADIUS:
			AudioManager.play_sound("select_soldier")
			transition_to_state(State.IDLE)

func handle_idle_state() -> void:
	if Input.is_action_just_pressed("left_click"):
		var click_pos = get_global_mouse_position()
		# If clicked far from character, return to inactive
		if position.distance_to(click_pos) > INTERACTION_RADIUS:
			AudioManager.play_sound("disselect_soldier")
			transition_to_state(State.INACTIVE)
		else:
			handle_movement_input()

func handle_movement_input() -> void:
	if not Input.is_action_just_pressed("left_click"):
		return
		
	var click_pos = get_global_mouse_position()
	
	# Check if click is outside interaction range
	if position.distance_to(click_pos) > INTERACTION_RADIUS:
		transition_to_state(State.INACTIVE)
		return
		
	var movement = calculate_grid_movement(click_pos)
	
	if movement != Vector2.ZERO:
		# Update sprite flip based on movement direction
		if movement.x != 0:
			animated_sprite_2d.flip_h = movement.x < 0
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
	if current_state == State.MOVING:
		return
		
	transition_to_state(State.MOVING)
	animated_sprite_2d.play("walk")
	
	var tween = create_tween()
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
