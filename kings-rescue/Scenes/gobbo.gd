extends CharacterBody2D
#class_name Monster
enum State {INACTIVE, IDLE, MOVING, DEAD}
@onready var up: Area2D = $Up
@onready var down: Area2D = $Down
@onready var left: Area2D = $Left
@onready var right: Area2D = $Right
var direction_check = false
@onready var center: Marker2D = $Center
@onready var game_manager = get_parent().get_parent()
@onready var monsters = get_parent()
var right_legal
var current_state
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var tween
const MOVE_TIME := 0.5  # Time in seconds to complete movement
var trap = false
var number
var role = "Monster"
var dead = false
@onready var leave: Area2D = $Leave
var leaving_board = false
var bite = false
@onready var up_trap: Area2D = $Up_trap
@onready var down_trap: Area2D = $Down_trap
@onready var left_trap: Area2D = $Left_trap
@onready var right_trap: Area2D = $Right_trap
var old_direct: Vector2
@onready var finder: Area2D = $Finder
var coin_array = []
var nearest_coin
var legal_move
var non_occupied = true
var king_direction
@onready var neighbours_check: Area2D = $Neighbours_check


func _ready() -> void:
	#print(position)
	pass

func _physics_process(_delta: float) -> void:
	#print(direction_check)
	self.leave_board()
	match current_state:
		State.IDLE:
			handle_idle_state()
		State.MOVING:
			# Movement is handled by tween, we just watch for new input
			pass
		State.DEAD:
			pass
	"""if len(win.get_overlapping_bodies()) > 0:
		leave_anim()"""
			
			
func goblin():
	pass


func move(body: Node2D) -> void:
	non_occupied = true
	#if direction_check == false:

	if dead:
		return
	else:
		var direct = monsters._get_direction("goblin", self)
		monsters.check_occupied(self, direct)
		if non_occupied:
			if direct.x != 0:
				animated_sprite_2d.flip_h = direct.x < 0
			#print("Goblin is moving ", direction)

			if direct.x > 0 and direct.y == 0:
				#print("right")
				legal_move = _check_square_to_move(right.get_overlapping_bodies())
			elif direct.x < 0 and direct.y == 0:
				#print("left")
				legal_move = _check_square_to_move(left.get_overlapping_bodies())
			elif direct.x == 0 and direct.y > 0:
				#print("down")
				legal_move = _check_square_to_move(down.get_overlapping_bodies())
			elif direct.x == 0 and direct.y < 0:
				#print("up")
				legal_move = _check_square_to_move(up.get_overlapping_bodies())
			if legal_move:
				move_character(direct)
			else:
				return
		
		#direction_check = true
	
func handle_idle_state() -> void:
	animated_sprite_2d.play()
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

func leave_board():
	if len(leave.get_overlapping_bodies()) > 0 and !leaving_board:
		leaving_board = true
		leave_anim()

func leave_anim():
	animated_sprite_2d.play("walk")
	game_manager.monsters.monsters.erase(self)
	var tween = create_tween()
	
	# Fade out over 1 second
	tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()  # Remove the node after fading out

func death():
	if tween != null:
		tween.kill()
	dead = true
	if animated_sprite_2d.animation != "death":
		animated_sprite_2d.play("death")
		transition_to_state(State.DEAD)


func _on_bumping_area_body_entered(body: Node2D) -> void:
	if body is Soldier:
		var direction = center.global_position.direction_to(body.center.global_position)
		#print(direction/3.14*180)
		if direction.x < 0 and direction.y == 0:
			#print("right")
			if len(right.get_overlapping_bodies()) > 0:
				body.turn_back()
				print(right.get_overlapping_bodies())
				#print("illegal")
			else:
				move_character(game_manager.troop.move_dir)
		elif direction.x > 0 and direction.y == 0:
			#print("left")
			if len(left.get_overlapping_bodies()) > 0:
				body.turn_back()
				#print("illegal")
			else:
				move_character(game_manager.troop.move_dir)
		elif direction.x == 0 and direction.y > 0:
			#print("up")
			if len(up.get_overlapping_bodies()) > 0:
				body.turn_back()
				#print("illegal")
			else:
				move_character(game_manager.troop.move_dir)
		elif direction.x == 0 and direction.y < 0:
			#print("down")
			if len(down.get_overlapping_bodies()) > 0:
				body.turn_back()
				#print("illegal")
			else:
				move_character(game_manager.troop.move_dir)
		game_manager.monsters.flip_direction("dog", number)
	elif body is King:
		tween.kill()
		if bite == false:
			bite = true
			animated_sprite_2d.play("attack")
			body.trap = true
			body.tween.kill()
			if !game_manager.party_ended:
				game_manager.end_party("trap", false)


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack":
		animated_sprite_2d.play("idle")
		
func _check_traps(direction):
	if len(right_trap.get_overlapping_areas()) > 0 and direction == "right":
		#print("Right trap found")
		return("trap")
	elif len(left_trap.get_overlapping_areas()) > 0 and direction == "left":
		#print("Left trap found")
		return("trap")
	elif len(up_trap.get_overlapping_areas()) > 0 and direction == "up":
		#print("Up trap found")
		return("trap")
	elif len(down_trap.get_overlapping_areas()) > 0 and direction == "down":
		#print("Down trap found")
		return("trap")

func find_coins():
	coin_array = []
	for stuff in finder.get_overlapping_areas():
		if stuff is Coin:
			coin_array.append(stuff)
	#print(coin_array)
			
func find_nearest_coin():
	if len(coin_array) > 0:
		var min = center.global_position.distance_to(coin_array[0].center.global_position)
		nearest_coin = coin_array[0]
		for stuff in coin_array:
			if center.global_position.distance_to(stuff.center.global_position) < min:
				min = center.global_position.distance_to(stuff.center.global_position)
				nearest_coin = stuff
		return(nearest_coin)
	else:
		return

func take_coin(coin):
	coin_array.erase(coin)
	
func _check_square_to_move(bodies):
	var illegal = true
	for i in bodies:
		if i is Soldier or i is King or i.has_method("goblin") or i.has_method("dog"):
			illegal = false
	return illegal


func _on_neighbours_check_body_entered(body: Node2D) -> void:
		if !dead:
			for bodies in neighbours_check.get_overlapping_bodies():
				if bodies.role=="King":
					if tween != null:
						tween.kill()
					king_direction = bodies.global_position - global_position
					if !game_manager.party_ended:
						animated_sprite_2d.flip_h = king_direction.x < 0
						AudioManager.play_sound("player_hurt")
						
						game_manager.end_party("assasination", false)
					if bite == false:
						bite = true
						animated_sprite_2d.play("attack")
						body.trap = true
						body.tween.kill()
