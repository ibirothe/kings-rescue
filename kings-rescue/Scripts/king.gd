extends CharacterBody2D
class_name King
enum State {INACTIVE, IDLE, MOVING}

var role = "King"
@onready var up: Area2D = $Up
@onready var down: Area2D = $Down
@onready var left: Area2D = $Left
@onready var right: Area2D = $Right
var direction_check = false
var dead = false
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
var win_check = false




func _ready() -> void:
	#print(position)
	pass
	
func _physics_process(_delta: float) -> void:
	#print(direction_check)
	if game_manager.party_ended and len(win.get_overlapping_bodies()) == 0 or trap == true:
		if not dead:
			animated_sprite_2d.play("death")
			AudioManager.play_sound("king_death", -8)
			dead = true
			print("it´s beeing played")
		return
		#NO IDEA WHY WE HAD THESE
	"""if game_manager.currently_moving == true:
		king_shape.disabled = true
	else:
		king_shape.disabled = false"""

	match current_state:
		State.IDLE:
			handle_idle_state()
		State.MOVING:
			# Movement is handled by tween, we just watch for new input
			pass
	if len(win.get_overlapping_bodies()) > 0:
		win_anim()
		if game_manager.party_ended == false:
			game_manager.end_party("flee", true)
			
			
func king():
	direction_check = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	#if direction_check == false:
	if body is Soldier:
		var direction = center.global_position.direction_to(body.center.global_position)
		print(direction/3.14*180)
		if direction.x < 0 and direction.y == 0:
			print("right")
			collision_check(right.get_overlapping_bodies(), body)
		if direction.x > 0 and direction.y == 0:
			print("left")
			collision_check(left.get_overlapping_bodies(), body)
		if direction.x == 0 and direction.y > 0:
			print("up")
			collision_check(up.get_overlapping_bodies(), body)
		if direction.x == 0 and direction.y < 0:
			print("down")
			collision_check(down.get_overlapping_bodies(), body)
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

func collision_check(guys, body):
	for bodies in guys:
		if bodies is Soldier:
			body.turn_back()
			print(right.get_overlapping_bodies())
			print("illegal")
			return
	move_character(game_manager.troop.move_dir)

func win_anim():
	animated_sprite_2d.play("walk")
	var tween = create_tween()
	
	# Fade out over 1 second
	tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()  # Remove the node after fading out
