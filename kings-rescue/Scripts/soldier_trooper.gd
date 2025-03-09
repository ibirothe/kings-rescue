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

# Shoppable Upgrades
var trapper = false
var paid = false

var number = 0
var subclass
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
var possible_assassination = false
var soldier_close = true
var dead = false
var king_direction
var move_dir
var tint_tween
var border_tween
var arrows_tween
var movement_tween
var coin_tween
var leaving_board = false
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

func _ready() -> void:
	# Start with default animation
	animated_sprite_2d.play(subclass+"_default")
	# Make selection indicator invisible
	square_border.self_modulate = Color(1,1,1,0)
	movement_arrows.self_modulate = Color(1,1,1,0)


func _physics_process(_delta: float) -> void:
	self.update_traits()
	# Soldier leaving the board
	self.leave_board()
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
			#handle_movement_input(move_dir)
			pass	
		State.DEAD:
			animated_sprite_2d.play(subclass+"_death")
			animated_sprite_2d.frame = 3
			
func update_traits() -> void:
	trapper = RunStats.upgrade_items.has("Trap Specialists")
	paid = RunStats.upgrade_items.has("Pay Mercenaries")
	
func assasination_check() -> bool:
	if assassin and !dead:
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
		if !game_manager.party_ended:
			animated_sprite_2d.flip_h = king_direction.x < 0
			animated_sprite_2d.play(subclass+"_attack")
			AudioManager.play_sound("player_hurt")
			
			game_manager.end_party("assasination", false)

func leave_board() -> void:
	if len(border_check.get_overlapping_bodies()) > 0 and !leaving_board:
		leaving_board = true
		stop_movement()
		disable_shader()
		visual_deactivation()
		active = false
		game_manager.active_soldier = false
		game_manager.currently_moving = false
		var text= subclass + game_manager.txt.ingame["soldier_leaving"].pick_random()
		GlobalText.set_text(text)
		coin_tween = create_tween()
		coin_tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
		await coin_tween.finished
		queue_free() 

func starvation_death() -> void:
	if game_manager:
		if game_manager.party_ended == true:
			if game_manager.food == 0:
				if game_manager.troop.soldiers.has(self):
					RunStats.soldiers_died += 1
					game_manager.troop.soldiers.erase(self)
				if animated_sprite_2d.animation != subclass+"_death":
					animated_sprite_2d.play(subclass+"_death")
			active = false
	else:
		game_manager = get_parent().get_parent()
		
func handle_inactive_state() -> void:
	if !game_manager.party_ended:
		self.animated_sprite_2d.play(subclass+"_default")

func handle_idle_state() -> void:
	 #, #GameManager.soldier_changing
	pass
	"""#Up for refractor
	if game_manager.soldier_changing == true and im_new == false:
		transition_to_state(State.INACTIVE)
	if game_manager.soldier_changing == false and im_new == true:
		im_new = false
		active = true"""

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
	
	# Flip character if needed
	if movement.x != 0:
		animated_sprite_2d.flip_h = movement.x < 0
	
	movement_tween = create_tween()
	movement_tween.tween_property(self, "position", 
		position + movement, MOVE_TIME
	).set_trans(Tween.TRANS_LINEAR)
	
	# When movement completes
	movement_tween.tween_callback(func():
		animated_sprite_2d.play(subclass+"_idle")
		transition_to_state(State.IDLE)
		game_manager.food = max(0, game_manager.food-1)
		movement_locked = false
		game_manager.currently_moving = false
		game_manager.refire_king() 
		) 
"""remove refire king"""

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
			game_manager.troop.activation_query(self)
		elif dead and game_manager.troop.current_soldier == null:
			GlobalText.set_text(game_manager.txt.ingame["dead_body"].pick_random())


func turn_back():
	print("turning back")
	if movement_tween:
		movement_tween.kill() # Stop the current tween
	# Create new tween to return to start
	movement_tween = create_tween()
	movement_tween.tween_property(self, "position", 
		movestart_position, MOVE_TIME
	).set_trans(Tween.TRANS_LINEAR)
	

	# When return movement completes
	movement_tween.tween_callback(func():
		animated_sprite_2d.play(subclass+"_idle")
		transition_to_state(State.IDLE)
		movement_locked = false
		game_manager.currently_moving = false
		game_manager.refire_king()
		)


func stop_movement():
	if movement_tween:
		movement_tween.kill() # Stop the current tween
		

func death():
	stop_movement()
	visual_deactivation()
	RunStats.soldiers_died += 1
	game_manager.troop.current_soldier = null
	game_manager.troop.soldiers.erase(self)
	if RunStats.upgrade_items.has("Life Insurance"):
		RunStats.add_coins(1)
		AudioManager.play_sound("coin_collect")
	if animated_sprite_2d.animation != subclass+"_death":
		animated_sprite_2d.play(subclass+"_death")
		

"""is that death?"""
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == subclass+"_death":
		collision_shape_2d.disabled = true
		game_manager.food = max(0, game_manager.food-1)
		dead = true
		transition_to_state(State.DEAD)
		active = false
		movement_locked = false

		game_manager.active_soldier = false
		game_manager.currently_moving = false
		await get_tree().create_timer(10).timeout
		var tween = create_tween()
		tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 2.0)
		await tween.finished
		queue_free()
		
		return
		
	if animated_sprite_2d.animation == subclass+"_attack":
		transition_to_state(State.IDLE)
		
		
		
func take_coin():
	game_manager.troop.soldiers.erase(self)
	coin_tween = create_tween()
	disable_shader()
	# Fade out over 1 second
	coin_tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
	await coin_tween.finished
	queue_free()  # Remove the node after fading out

func visual_activation():
	
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
	tint_tween = create_tween()
	tint_tween.tween_method(func(value): 
		animated_sprite_2d.material.set_shader_parameter("tint_effect", value), 
		0.2, 0.4, 0.4)
	border_tween = create_tween()
	border_tween.tween_property(square_border, "self_modulate:a", 0.9, 1.5)
	animation_player.play("Border_blink")
	arrows_tween = create_tween()
	arrows_tween.tween_property(movement_arrows, "self_modulate:a", 0.9, 1.5)
	#await tween2.finished

func visual_deactivation():
	tint_tween.kill()
	border_tween.kill()
	arrows_tween.kill()
	"""if !animated_sprite_2d.material:
		return"""
	# Tween the shader parameter
	#await tween1.finished
	#await tween2.finished
	disable_shader()
	animation_player.stop()
	border_tween = create_tween()
	border_tween.tween_property(square_border, "self_modulate:a", 0.0, 0.5)
	var arrows_tween = create_tween()
	arrows_tween.tween_property(movement_arrows, "self_modulate:a", 0.0, 0.5)

"""Movement click signals"""
func _on_right_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		send_move_click("right")


func _on_left_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		send_move_click("left")


func _on_down_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		send_move_click("down")

func _on_up_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		send_move_click("up")
		
func send_move_click(direction):
	if 	game_manager.troop.current_soldier == self:
		game_manager.troop.movement_query(direction, self)
	
func _on_bumping_area_body_entered(body: Node2D) -> void:
	if body.subclass != self.subclass and game_manager.troop.current_soldier != self and dead == false:
		body.turn_back()
		
func soldier():
	pass	
	#just for bumping purposes

# 
func _on_neighbours_check_body_exited(body: Node2D) -> void:
		if body.role == "Soldier":
			if assassin == true:
				soldier_close = false
		elif body.role == "King":
			if assassin == true:
				possible_assassination = false

func disable_shader():
	tint_tween.kill
	animated_sprite_2d.material = null
