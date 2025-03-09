extends CharacterBody2D
#class_name Monster
enum State {INACTIVE, IDLE, MOVING, DEAD}
@onready var up: Area2D = $Up
@onready var down: Area2D = $Down
@onready var left: Area2D = $Left
@onready var right: Area2D = $Right
var direction_check = false
@onready var center: Marker2D = $Center
@onready var king_shape: CollisionShape2D = $King_shape
@onready var game_manager = get_parent().get_parent()
@onready var monsters = get_parent()
var right_legal
var current_state
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var tween
const MOVE_TIME := 0.5  # Time in seconds to complete movement
@onready var win: Area2D = $Win
var trap = false
var number
var role = "Monster"
var dead = false
@onready var leave: Area2D = $Leave
var leaving_board = false
var bite = false


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
			
			
func dog():
	pass


func move(body: Node2D) -> void:
	#if direction_check == false:

	if dead:
		return
	else:
		var direction = monsters._get_direction("dog", self)
		if direction.x != 0:
			animated_sprite_2d.flip_h = direction.x < 0
		print("Doggo is moving ", direction)

		if direction.x > 0 and direction.y == 0:
			print("right")
			if len(right.get_overlapping_bodies()) > 0:
				print(right.get_overlapping_bodies())
				print("illegal")
			else:
				move_character(direction)
		elif direction.x < 0 and direction.y == 0:
			print("left")
			if len(left.get_overlapping_bodies()) > 0:
				print(left.get_overlapping_bodies())
				print("illegal")
			else:
				move_character(direction)
		elif direction.x == 0 and direction.y > 0:
			print("up")
			if len(up.get_overlapping_bodies()) > 0:
				print(up.get_overlapping_bodies())
				print("illegal")
			else:
				move_character(direction)
		elif direction.x == 0 and direction.y < 0:
			print("down")
			if len(down.get_overlapping_bodies()) > 0:
				print(down.get_overlapping_bodies())
				print("illegal")
			else:
				move_character(direction)
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
	tween.kill()
	dead = true
	if animated_sprite_2d.animation != "death":
		animated_sprite_2d.play("death")
		transition_to_state(State.DEAD)


func _on_bumping_area_body_entered(body: Node2D) -> void:
	if body is Soldier:
		var direction = center.global_position.direction_to(body.center.global_position)
		print(direction/3.14*180)
		if direction.x < 0 and direction.y == 0:
			print("right")
			if len(right.get_overlapping_bodies()) > 0:
				body.turn_back()
				print(right.get_overlapping_bodies())
				print("illegal")
			else:
				move_character(game_manager.troop.move_dir)
		elif direction.x > 0 and direction.y == 0:
			print("left")
			if len(left.get_overlapping_bodies()) > 0:
				body.turn_back()
				print("illegal")
			else:
				move_character(game_manager.troop.move_dir)
		elif direction.x == 0 and direction.y > 0:
			print("up")
			if len(up.get_overlapping_bodies()) > 0:
				body.turn_back()
				print("illegal")
			else:
				move_character(game_manager.troop.move_dir)
		elif direction.x == 0 and direction.y < 0:
			print("down")
			if len(down.get_overlapping_bodies()) > 0:
				body.turn_back()
				print("illegal")
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
