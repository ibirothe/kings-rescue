extends Node

@export var SFXvolume: float = 1
@export var SYSvolume: float = 1
@export var MSCvolume: float = 1

# Constants
const PLAYERS_PER_SOUND = 3
const SFX_DIRECTORY = "res://Assets/SFX/"
const MUSIC_DIRECTORY = "res://Assets/Music/"

# Audio resource storage
var _sound_effects: Dictionary = {}
var _audio_players: Dictionary = {}
var _looping_sounds: Dictionary = {}
var _sound_instances: Dictionary = {}

# Music management
var _music_player: AudioStreamPlayer
var _current_music: Dictionary = {
	"name": "",
	"should_loop": true,
	"stream": null
}

func _ready():
	_load_sound_effects()
	_create_audio_players()
	_setup_music_player()

func _load_sound_effects():
	# Preload specific sounds (recommended for exports)
	# Replace these examples with your actual sound files
	_sound_effects = {
		"ambience": preload("res://Assets/SFX/ambience.wav"),
		"disselect_soldier": preload("res://Assets/SFX/disselect_soldier.wav"),
		"food_collect": preload("res://Assets/SFX/food_collect.wav"),
		"mercenary_flee": preload("res://Assets/SFX/mercenary_flee.wav"),
		"player_death": preload("res://Assets/SFX/player_death.wav"),
		"player_hurt": preload("res://Assets/SFX/player_hurt.wav"),
		"player_run": preload("res://Assets/SFX/player_run.wav"),
		"remove_trap": preload("res://Assets/SFX/food_collect.wav"),
		"select_soldier": preload("res://Assets/SFX/select_soldier.wav")
	}


func _create_audio_players():
	for sound_name in _sound_effects.keys():
		_audio_players[sound_name] = []
		for i in PLAYERS_PER_SOUND:
			var player = AudioStreamPlayer.new()
			player.stream = _sound_effects[sound_name]
			player.bus = "SFX"
			add_child(player)
			_audio_players[sound_name].append(player)

func _setup_music_player():
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	_music_player.connect("finished", _on_music_finished)
	add_child(_music_player)

func play_sound(
	sound_name: String, 
	volume_db: float = 0.0, 
	pitch_scale: float = 1.0, 
	loop: bool = false, 
	distance: float = 0.0, 
	radius: float = 0.0,
	instance_id: Variant = null
) -> void:
	if not _sound_effects.has(sound_name):
		push_warning("Sound effect '%s' not found!" % sound_name)
		return
	
	var final_volume_db = calculate_volume_by_distance(volume_db, distance, radius)
	var available_player = _find_available_player(sound_name)
	
	_configure_player(available_player, final_volume_db, pitch_scale)
	
	if loop:
		_handle_looping_sound(available_player, sound_name, instance_id)

func _find_available_player(sound_name: String) -> AudioStreamPlayer:
	for player in _audio_players[sound_name]:
		if not player.playing:
			return player
	
	# Reuse first player if no available players
	var player = _audio_players[sound_name][0]
	player.stop()
	return player

func _configure_player(
	player: AudioStreamPlayer, 
	volume_db: float, 
	pitch_scale: float
) -> void:
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()

func is_looping_sound_active(sound_name: String, instance_id: Variant = null) -> bool:
	# Use instance_id for more specific tracking if provided
	var unique_sound_key = sound_name + (str(instance_id) if instance_id != null else "")
	return _looping_sounds.has(unique_sound_key)

func _handle_looping_sound(
	player: AudioStreamPlayer, 
	sound_name: String, 
	instance_id: Variant = null
) -> void:
	var unique_sound_key = sound_name + (str(instance_id) if instance_id != null else "")
	
	# Stop any existing looping sound with the same key
	stop_looping_sound(sound_name, instance_id)
	
	# Connect finished signal
	if player.is_connected("finished", Callable(self, "_on_looping_sound_finished")):
		player.disconnect("finished", Callable(self, "_on_looping_sound_finished"))
	
	player.connect("finished", Callable(self, "_on_looping_sound_finished").bind(unique_sound_key))
	_looping_sounds[unique_sound_key] = player
	
	# Track sound instance if ID provided
	if instance_id != null:
		_sound_instances[unique_sound_key] = instance_id

func _on_looping_sound_finished(sound_name: String) -> void:
	if _looping_sounds.has(sound_name):
		_looping_sounds[sound_name].play()

func set_looping_sound_volume(sound_name: String, volume_db: float, instance_id: Variant = null) -> void:
	# Use instance_id for more specific tracking if provided
	var unique_sound_key = sound_name + (str(instance_id) if instance_id != null else "")
	
	if _looping_sounds.has(unique_sound_key):
		_looping_sounds[unique_sound_key].volume_db = volume_db

func stop_looping_sound(sound_name: String, instance_id: Variant = null) -> void:
	var unique_sound_key = sound_name + (str(instance_id) if instance_id != null else "")
	
	if _looping_sounds.has(unique_sound_key):
		var player = _looping_sounds[unique_sound_key]
		player.stop()
		
		if player.is_connected("finished", Callable(self, "_on_looping_sound_finished")):
			player.disconnect("finished", Callable(self, "_on_looping_sound_finished"))
		
		_looping_sounds.erase(unique_sound_key)
		
		if instance_id != null:
			_sound_instances.erase(unique_sound_key)

func play_music(track_name: String, volume_db: float = 0.0, loop: bool = true) -> void:
	# Use ResourceLoader instead of file existence check
	var music_stream
	
	var music_tracks = {
		"title": preload("res://Assets/Music/bg_music.wav"),
		"win_jingle": preload("res://Assets/Music/win_jingle.wav"),
		"lose_jingle": preload("res://Assets/Music/lose_jingle.wav")
	}
	
	if music_tracks.has(track_name):
		music_stream = music_tracks[track_name]
	else:
		# Fallback to dynamic loading (may not work in exports)
		var path = MUSIC_DIRECTORY + track_name + ".wav"
		music_stream = ResourceLoader.load(path)
		
		if not music_stream:
			push_warning("Music track '%s' not found!" % track_name)
			return
	
	# Store current music details
	_current_music = {
		"name": track_name,
		"should_loop": loop,
		"stream": music_stream
	}
	
	# Configure and play music
	_music_player.stream = music_stream
	_music_player.volume_db = volume_db
	_music_player.play()

func _on_music_finished() -> void:
	# Check if the current music should loop
	if _current_music.get("should_loop", false):
		_music_player.play()
	else:
		# Optional: implement playlist logic or other behavior
		pass

func calculate_volume_by_distance(
	base_volume_db: float, 
	distance: float, 
	radius: float
) -> float:
	if distance <= 0 or radius <= 0:
		return base_volume_db
	
	if distance <= radius:
		return base_volume_db
	
	if distance <= radius * 4:
		var t = (distance - radius) / (radius * 3)
		return lerp(base_volume_db, base_volume_db - 30.0, t)
	
	return base_volume_db - 30.0

func pause_music() -> void:
	if _music_player:
		_music_player.stream_paused = true

func resume_music() -> void:
	if _music_player:
		_music_player.stream_paused = false

func stop_music() -> void:
	if _music_player:
		_music_player.stop()
	
	# Reset current music state
	_current_music = {
		"name": "",
		"should_loop": true,
		"stream": null
	}

func is_music_playing() -> bool:
	return _music_player and _music_player.playing

func stop_all_sounds():
	# Stop non-looping sounds
	for players in _audio_players.values():
		for player in players:
			player.stop()
	
	# Stop looping sounds
	for sound_name in _looping_sounds.keys():
		stop_looping_sound(sound_name)
	
	# Stop music
	stop_music()
	
	# Clear sound instances tracking
	_sound_instances.clear()

func _exit_tree():
	stop_all_sounds()
