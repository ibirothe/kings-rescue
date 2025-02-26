extends CharacterBody2D

class_name Soldier
enum State {INACTIVE, IDLE, MOVING, DEAD}
@onready var game_manager: Node2D = get_parent().get_parent()
@onready var neighbours_check: Area2D = $Neighbours_check
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var current_state: State = State.INACTIVE  # Start as INACTIVE
const MOVE_DISTANCE := 16.0
const MOVE_TIME := 0.5  # Time in seconds to complete movement
const INTERACTION_RADIUS := 24.0
var target_position := Vector2.ZERO
var assassin = false
var mercenary = false

var number = 0
var subclass
var click_resolved = false
var im_new = true
var active = false
var next_cycle = false
var cycle_sync = false
var movement_locked = false
var movement = Vector2.ZERO
var role
var bodies
var movestart_position
var returning = false
var tween
var dead = false
var king_direction
var move_dir
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var border_check: Area2D = $Border_check
@onready var square_border: AnimatedSprite2D = $Square_border
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var movement_arrows: AnimatedSprite2D = $Movement_arrows
@onready var center: Marker2D = $Center

var blue_shader_material = ShaderMaterial.new()
var blue_shader_code = """
	shader_type canvas_item;
	uniform vec4 tint_color : source_color = vec4(0.0, 0.2, 0.7, 0.7);
	uniform float tint_effect : hint_range(0.0, 1.0) = 0.0;
	
	void fragment() {
		vec4 texture_color = texture(TEXTURE, UV);
		// Mix the colors but preserve original alpha
		vec4 final_color = mix(texture_color, vec4(tint_color.rgb, texture_color.a), tint_effect);
		// Only apply tint where the sprite is visible (non-transparent)
		COLOR = vec4(final_color.rgb, texture_color.a);
	}
	"""

const CHARACTER_DESCRIPTIONS = {
	"Rupert": "Rupert has been in the guard for 45 years. The only thing he fears more than death is retirement.",
	"Thoralf": "Thoralf is an older wizard making inappropriate jokes sometimes. We try not to laugh, but it's hard at times.",
	"Ogra": "Ogra has trained for the King's Guard since she was a little girl. No way she's an imposter.",
	"Bartholo": "Bartholo wanted to be an inventor, but his parents said no. So he became a video game character.",
	"Ibrahim": "Ibrahim is a loyal kingsman. At least, that's what I assume. Placing him next to a Gold Coin will bring some clarity.",
	"Edwin": "Edwin's singing voice sounds like birds in spring. Unfortunately, we didn't hire voice actors to prove it.",
	"Marquise": "Marquise's archery is masterful. Sadly, the developers didn't put arrows in the game.",
	"Arianna": "Arianna joined the King's Guard recently. She had exceptional results in the job interview."
}

func _ready() -> void:
	# Start with default animation
	animated_sprite_2d.play(subclass+"_default")
	# Make selection indicator invisible
	square_border.self_modulate = Color(1,1,1,0)
	movement_arrows.self_modulate = Color(1,1,1,0)


func _physics_process(_delta: float) -> void:
	# Soldier leaving the board
	self.board_leave_check()
	# Check if food ran out
	self.starvation_death()
	# Assasinate if possible
	self.assasination()

	match current_state:
		State.INACTIVE:
			handle_inactive_state()
		State.IDLE:
			handle_idle_state()
		State.MOVING:
			# Movement is handled by tween, we just watch for new input
			handle_movement_input(move_dir)
		State.DEAD:
			animated_sprite_2d.play(subclass+"_death")
			animated_sprite_2d.frame = 3
			
	if click_resolved == true:
		click_resolved == false

func assasination_check() -> bool:
	var possible_assassination = false
	var soldier_close = true
	if assassin == true and dead == false:
		for bodies in neighbours_check.get_overlapping_bodies():
			if bodies.role=="King":
				king_direction = bodies.global_position - global_position
				possible_assassination = true
			if bodies.role=="Soldier":
				if bodies.dead != true:
					soldier_close = true
	return possible_assassination and !soldier_close

func assasination() -> void:
	if self.assasination_check():
		if animated_sprite_2d.animation != subclass+"_attack":
			if king_direction.x < 0:
				animated_sprite_2d.flip_h = true
			else:
				animated_sprite_2d.flip_h = false
			animated_sprite_2d.play(subclass+"_attack")

		if game_manager.party_ended == false:
			GlobalDifficulty.losses +=1
			var lose_text = "Without cautious eyes watching, the assassins were able to kill the King. Your mission failed, the King is dead. Long live the King! \n \nWINS: " + str(GlobalDifficulty.wins) + "\n \nLOSSES: " + str(GlobalDifficulty.losses) + "\n \nDIFFICULTY: " + str(GlobalDifficulty.difficulty_name()) + "\n \nHistory keeps repeating itself, and strangely, there are always two Assassins within the King's Guard. Press 'R' to restart… and trust no one!"
			GlobalText.set_text("")
			game_manager.win_fade_out(lose_text)
			game_manager.party_ended = true
			AudioManager.play_sound("player_hurt")

func board_leave_check() -> void:
	if len(border_check.get_overlapping_bodies()) > 0:
		stop_movement()
		active = false
		game_manager.active_soldier = false
		game_manager.click_resolved = false
		game_manager.currently_moving = false
		var text=subclass + " left. Hope they bring some help. Godspeed."
		GlobalText.set_text(text)
		queue_free()

func starvation_death() -> void:
	if game_manager:
		if game_manager.party_ended == true:
			if game_manager.food == 0:
				if animated_sprite_2d.animation != subclass+"_death":
					animated_sprite_2d.play(subclass+"_death")
			active = false
	else:
		game_manager = get_parent().get_parent()
		
func handle_inactive_state() -> void:
	self.animated_sprite_2d.play(subclass+"_default")

func handle_idle_state() -> void:
	 #, #GameManager.soldier_changing
	if game_manager.soldier_changing == true and im_new == false:
		transition_to_state(State.INACTIVE)
	if game_manager.soldier_changing == false and im_new == true:
		im_new = false
		active = true


func handle_movement_input(move_dir) -> void:
	match current_state:
		State.INACTIVE:
			return
	if not Input.is_action_just_pressed("left_click") or game_manager.party_ended:
		return

	if game_manager.soldier_in_a_way == true and im_new == false:
		#print("Guy in a way")
		transition_to_state(State.INACTIVE)
		visual_deactivation()
		return
	if game_manager.soldier_changing == true and im_new == false:
		transition_to_state(State.INACTIVE)
		im_new = true
		active = false
		visual_deactivation()
		return
	if movement_locked == false and active == true: 
		movestart_position = position
		match move_dir:
			"up": movement = Vector2(0, -16)
			"down": movement = Vector2(0, 16)
			"left": movement = Vector2(-16, 0)
			"right": movement = Vector2(16,0)
			
		game_manager.currently_moving = true
		movement_locked = true
		print("Assassin - ", assassin)
		print("Mercenary - ", mercenary)

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
	if current_state == State.MOVING:
		return
	transition_to_state(State.MOVING)
	animated_sprite_2d.play(subclass+"_walk")

	tween = create_tween()
	tween.tween_property(self, "position", 
		position + movement, MOVE_TIME
	).set_trans(Tween.TRANS_LINEAR)
	
	# When movement completes
	tween.tween_callback(func():
		animated_sprite_2d.play(subclass+"_idle")
		transition_to_state(State.IDLE)
		game_manager.food = max(0, game_manager.food-1)
		movement_locked = false
		game_manager.currently_moving = false
		game_manager.refire_king()
		)


func transition_to_state(new_state: State) -> void:
	match new_state:
		State.INACTIVE:
			animated_sprite_2d.play(subclass+"_default")
			im_new = true

	current_state = new_state

# Activate soldier on click
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click") and !game_manager.party_ended:
		if !dead and !active:
			game_manager.troop.activate_soldier(self)


func turn_back():
	if tween:
		tween.kill() # Stop the current tween
	# Create new tween to return to start
	tween = create_tween()
	tween.tween_property(self, "position", 
		movestart_position, MOVE_TIME
	).set_trans(Tween.TRANS_LINEAR)
	

	# When return movement completes
	tween.tween_callback(func():
		animated_sprite_2d.play(subclass+"_idle")
		transition_to_state(State.IDLE)
		movement_locked = false
		game_manager.currently_moving = false
		game_manager.refire_king()
		)

func stop_movement():
	if tween:
		tween.kill() # Stop the current tween
		

func death():
	stop_movement()
	visual_deactivation()
	click_resolved == true

	if animated_sprite_2d.animation != subclass+"_death":
		animated_sprite_2d.play(subclass+"_death")
		


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == subclass+"_death":
		print("Handling death")
		collision_shape_2d.disabled = true
		game_manager.food = max(0, game_manager.food-1)
		dead = true
		print("Im dead")
		transition_to_state(State.DEAD)
		active = false
		movement_locked = false
		if game_manager.soldier_changing == false:
			game_manager.active_soldier = false
			im_new = true
			active = false
		game_manager.active_soldier = false
		game_manager.click_resolved = false
		game_manager.currently_moving = false
		return
		
func take_coin():
	tween = create_tween()
	# Fade out over 1 second
	tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()  # Remove the node after fading out

func visual_activation():
	print("Visual activation")
	
	# Create a shader material with an improved shader
	var shader_material = ShaderMaterial.new()
	var shader_code = """
	shader_type canvas_item;
	uniform vec4 tint_color : source_color = vec4(0.0, 0.2, 0.7, 0.7);
	uniform float tint_effect : hint_range(0.0, 1.0) = 0.0;
	
	void fragment() {
		vec4 texture_color = texture(TEXTURE, UV);
		// Mix the colors but preserve original alpha
		vec4 final_color = mix(texture_color, vec4(tint_color.rgb, texture_color.a), tint_effect);
		// Only apply tint where the sprite is visible (non-transparent)
		COLOR = vec4(final_color.rgb, texture_color.a);
	}
	"""
	
	# Create shader and apply it
	blue_shader_material.shader = Shader.new()
	blue_shader_material.shader.code = blue_shader_code
	animated_sprite_2d.material = blue_shader_material
	
	# Tween the shader parameter
	tween = create_tween()
	tween.tween_method(func(value): 
		animated_sprite_2d.material.set_shader_parameter("tint_effect", value), 
		0.2, 0.4, 0.4)
	var tween1 = create_tween()
	tween1.tween_property(square_border, "self_modulate:a", 0.9, 1.5)
	animation_player.play("Border_blink")
	var tween2 = create_tween()
	tween2.tween_property(movement_arrows, "self_modulate:a", 0.9, 1.5)
	await tween2.finished

func visual_deactivation():
	if !animated_sprite_2d.material or !active:
		return
	print("Visual deactivation")
	# Tween the shader parameter
	tween = create_tween()
	tween.tween_method(func(value): 
		animated_sprite_2d.material.set_shader_parameter("tint_effect", value), 
		0.0, 0.0, 0.0)
	animation_player.stop()
	var tween1 = create_tween()
	tween1.tween_property(square_border, "self_modulate:a", 0.0, 0.5)
	var tween2 = create_tween()
	tween2.tween_property(movement_arrows, "self_modulate:a", 0.0, 0.5)

		

func _on_right_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		if game_manager.inside_board:
			# Check if click position is not within another soldier's ActivationArea
			var mouse_pos = get_viewport().get_mouse_position()
			var overlapping_areas = false
			# Get all soldiers in the scene
			for soldier in game_manager.troop.soldiers:
				# Skip checking against self
				if soldier == self:
					continue
					
				# Get the ActivationArea node of the soldier
				var activation_area = soldier.get_node("Activation_area")
				
				# Check if the mouse position is within the area
				if activation_area.get_global_rect().has_point(mouse_pos):
					overlapping_areas = true
					break
			
			# Only handle movement if not overlapping with other ActivationAreas
			if not overlapping_areas:
				move_dir = "right"
				handle_movement_input(move_dir)


func _on_left_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		if game_manager.inside_board:
			move_dir = "left"
			handle_movement_input(move_dir)


func _on_down_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		if game_manager.inside_board:
			move_dir = "down"
			handle_movement_input(move_dir)


func _on_up_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		if game_manager.inside_board:
			move_dir = "up"
			handle_movement_input(move_dir)
			
