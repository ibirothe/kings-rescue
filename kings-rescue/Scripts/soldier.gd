extends CharacterBody2D

class_name Soldier
enum State {INACTIVE, IDLE, MOVING, DEAD}
@onready var game_manager: Node2D = get_parent()
@onready var neighbours_check: Area2D = $Neighbours_check
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var current_state: State = State.INACTIVE  # Start as INACTIVE
const MOVE_DISTANCE := 16.0
const MOVE_TIME := 0.5  # Time in seconds to complete movement
const INTERACTION_RADIUS := 24.0
var target_position := Vector2.ZERO
var assassin = false
var mercenary = false
var possible_assassination = false
var soldier_close = true
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
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var border_check: Area2D = $Border_check


@onready var center: Marker2D = $Center
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
	

func _physics_process(_delta: float) -> void:
	#check end condition
	if len(border_check.get_overlapping_bodies()) > 0:
		stop()
		active = false
		get_parent().active_soldier = false
		get_parent().click_resolved = false
		get_parent().currently_moving = false
		queue_free()
		#AudioManager.play_sound("mercenary_flee")
		var text=subclass + " left. Hope they bring some help. Godspeed."
		GlobalText.set_text(text)
		queue_free()
	if game_manager:
		if game_manager.party_ended == true:
			if game_manager.food == 0:
				if animated_sprite_2d.animation != subclass+"_death":
					animated_sprite_2d.play(subclass+"_death")
			active = false
	else:
		game_manager = get_parent()
		
	if active == true:
		#print(possible_assassination, soldier_close)
		pass
	if assassin == true and dead == false:
		for bodies in neighbours_check.get_overlapping_bodies():
			if bodies.role=="King":
				king_direction = bodies.global_position - global_position
				#print("Possible_Assassination")
				possible_assassination = true
			if bodies.role=="Soldier":
				if bodies.dead == true:
					pass
				else:
				#print("Should be impossible")
					soldier_close = true
		#print(possible_assassination, soldier_close)
		if possible_assassination == true and soldier_close == false:
			if animated_sprite_2d.animation != subclass+"_attack":
				if king_direction.x < 0:
					animated_sprite_2d.flip_h = true
				else:
					animated_sprite_2d.flip_h = false
				animated_sprite_2d.play(subclass+"_attack")
			if !game_manager.party_ended:
				AudioManager.play_sound("")
				game_manager.party_ended = true
				GlobalText.set_text("Without cautious eyes watching, the assassins were able to kill the King. Your mission failed, the King is dead. Long live the King!")

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
		State.DEAD:
			animated_sprite_2d.play(subclass+"_death")
			animated_sprite_2d.frame = 3
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
		var click_distance = click_pos-center.global_position
		
		print(click_distance)
		if abs(click_distance.x) > INTERACTION_RADIUS or abs(click_distance.y) > INTERACTION_RADIUS or abs(click_distance.x) > 8 and abs(click_distance.y) > 8:
			print("too Far")
			AudioManager.play_sound("disselect_soldier")
			
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
		movestart_position = position
		movement = calculate_grid_movement(click_pos)
		get_parent().currently_moving = true
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
		

	#print(get_parent().soldier_in_a_way, im_new)
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
		get_parent().movement_resolved(possible_assassination, soldier_close)
		get_parent().food = max(0, get_parent().food-1)
		movement_locked = false
		get_parent().currently_moving = false
		get_parent().refire_king()
		)
	# Add method to stop movement

func transition_to_state(new_state: State) -> void:
	match new_state:
		State.INACTIVE:
			animated_sprite_2d.play(subclass+"_default")
			active = false
			im_new = true
		State.IDLE:
			animated_sprite_2d.play(subclass+"_idle")
	
	current_state = new_state


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		if dead == true:
			GlobalText.set_text("He's dead, Jim.")
		else:
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
			GlobalText.set_text(CHARACTER_DESCRIPTIONS[subclass], subclass)

"""
func _on_neighbours_check_body_entered(body: Node2D) -> void:
	if body.has_node("King"):
		if assassin == true:
			print("Possible_Assassination")
			possible_assassination = true
	elif body.role == "Soldier":
		if assassin == true:
			print("Should be impossible")
			soldier_close = true"""


func _on_neighbours_check_body_exited(body: Node2D) -> void:
		if body.role == "Soldier":
			if assassin == true:
				soldier_close = false
		elif body.role == "King":
			if assassin == true:
				possible_assassination = false

func turn_back():
	print("Returning")
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
		get_parent().currently_moving = false
		get_parent().refire_king()
		)
func stop():
	if tween:
		tween.kill() # Stop the current tween
func death():
	stop()
	click_resolved == true

	#
	if animated_sprite_2d.animation != subclass+"_death":
		animated_sprite_2d.play(subclass+"_death")
		


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == subclass+"_death":
		print("Handling death")
		collision_shape_2d.disabled = true
		get_parent().food = max(0, get_parent().food-1)
		dead = true
		print("Im dead")
		transition_to_state(State.DEAD)
		active = false
		movement_locked = false
		if get_parent().soldier_changing == false:
			get_parent().active_soldier = false
			im_new = true
			active = false
		get_parent().active_soldier = false
		get_parent().click_resolved = false
		get_parent().currently_moving = false
		return
		
