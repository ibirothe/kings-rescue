extends Area2D

@onready var game_manager: Node2D = get_parent()
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var trap_disabled = false

func _ready():
	body_entered.connect(_on_body_entered)
	animated_sprite_2d.play("default")

func _on_body_entered(body):
	if trap_disabled:
		return
		
	if body is Soldier:
		handle_soldier_interaction(body)
	if body.role == "Monster":
		handle_monster_interaction(body)
	elif body.has_method("king"):
		handle_king_interaction(body)

func handle_soldier_interaction(soldier):
	if soldier.trapper:
		var dismantle_success = attempt_trap_dismantle()
		if dismantle_success:
			return
		
	trigger_trap()
	kill_soldier(soldier)

func handle_monster_interaction(monster):
	trigger_trap()
	kill_monster(monster)
	

func attempt_trap_dismantle() -> bool:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var success = rng.randi_range(0, 1) == 0
	
	if success:
		disable_trap()
		fade_out_and_remove()
	return success

func disable_trap():
	animated_sprite_2d.modulate.a = 0
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(animated_sprite_2d, "modulate:a", 1, 0.6)
	AudioManager.play_sound("remove_trap")
	animated_sprite_2d.play("disabled")
	trap_disabled = true
	GlobalText.set_text(game_manager.txt.ingame["dismantle_trap"].pick_random())

func fade_out_and_remove():
	await get_tree().create_timer(10).timeout
	var tween = create_tween()
	tween.tween_property(animated_sprite_2d, "self_modulate:a", 0.0, 2.0)
	await tween.finished
	queue_free()

func trigger_trap():
	animated_sprite_2d.play("trigger")
	AudioManager.play_sound("player_hurt")
	await get_tree().create_timer(0.9).timeout
	AudioManager.play_sound("cross_out", -10)
	

func kill_soldier(soldier):
	soldier.animated_sprite_2d.play(soldier.subclass + "_death")
	GlobalText.set_text(game_manager.txt.ingame["soldier_trap_death"].pick_random())
	soldier.death()
	soldier.z_index = 0
	game_manager.movement_complete()
	if AudioManager.is_looping_sound_active("player_run"):
			AudioManager.stop_looping_sound("player_run")

func kill_monster(monster):
	monster.animated_sprite_2d.play("death")
	monster.death()
	monster.z_index = 0

func handle_king_interaction(king):
	trigger_trap()
	king.trap = true
	
	if !game_manager.party_ended:
		game_manager.end_party("trap", false)
