
extends Node

# Global game state and scene switching manager

# Signal emitted whenever the screen shake factor changes.
signal screen_shake_factor_changed(new_value: float)

# Audio
const MUSIC_TRACK = preload("res://assets/audio/music/Lofi hip hop Volume 1) - 06 - Soft Lights (Loop Version).mp3")
var music: AudioStreamPlayer

# Tutorial state flag
var tutorial_watched: bool = false

# Scoring
var score: int = 0
var high_score: int = 0

# Screen shake dampen factor
# We'll use a setter to clamp and snap the value, and emit a signal on change.
var _screen_shake_factor: float = 1.0
var screen_shake_factor: float setget set_screen_shake_factor, get_screen_shake_factor

func set_screen_shake_factor(value: float) -> void:
	# Clamp between 0.0 and 1.0, then snap to the nearest 0.1 increment.
	_screen_shake_factor = snapped(clampf(value, 0.0, 1.0), 0.1)
	emit_signal("screen_shake_factor_changed", _screen_shake_factor)

func get_screen_shake_factor() -> float:
	return _screen_shake_factor

# Screen flash enabled/disabled setting
var screen_flash_enabled: bool = true

# Scene management: current active scene
var current_scene: Node = null

func _ready() -> void:
	# Set the current scene from the SceneTree's current_scene.
	current_scene = get_tree().current_scene
	
	# Load settings from persistent storage.
	load_settings()
	
	# Prepare the music stream.
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	music.stream = MUSIC_TRACK
	# Process mode set to ALWAYS so music continues even if the game is paused.
	music.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music)

func save_settings() -> void:
	# Save settings to "user://settings" using CSV format.
	var file = FileAccess.open("user://settings", FileAccess.WRITE)
	if file:
		# Format: master volume, music volume, effects volume, screen shake factor, screen flash enabled, high_score, tutorial watched
		var settings = PackedStringArray([
			str(snapped(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))), 0.01)),
			str(snapped(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))), 0.01)),
			str(snapped(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects"))), 0.01)),
			str(screen_shake_factor),
			str(screen_flash_enabled),
			str(high_score),
			str(tutorial_watched)
		])
		file.store_csv_line(settings)
		file.close()

func load_settings() -> void:
	# Load settings from "user://settings". If the file doesn't exist, use default values.
	var file = FileAccess.open("user://settings", FileAccess.READ)
	if file:
		var settings = file.get_csv_line()
		file.close()
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(float(settings[0])))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(float(settings[1])))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(float(settings[2])))
		screen_shake_factor = float(settings[3])
		screen_flash_enabled = (settings[4] == "true")
		high_score = int(settings[5])
		tutorial_watched = (settings[6] == "true")
	else:
		# Set default bus volumes if settings file is not found.
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(0.5))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(0.5))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(0.5))

func play_music_track() -> void:
	# Start playing music if it's not already playing.
	if not music.playing:
		music.play()

## Scene switching functions

# Initiate scene switch via a deferred call.
func goto_scene(path: String) -> void:
	# Use call_deferred to allow current frame processing to complete safely.
	_deferred_goto_scene.call_deferred(path)

# Deferred function to load a new scene and free the current one.
func _deferred_goto_scene(path: String) -> void:
	if current_scene:
		current_scene.free()
	# Load and instantiate the new scene.
	current_scene = ResourceLoader.load(path).instantiate()
	# Add the new scene as a child of the root node.
	get_tree().root.add_child(current_scene)
	# Update the SceneTree's current_scene reference.
	get_tree().current_scene = current_scene

## Utility function

# Formats a large integer with commas as thousands separators.
func format_large_integer(num: int) -> String:
	var str_num: String = str(num)
	var size: int = str_num.length()
	var formatted: String = ""
	for i in range(size):
		# Insert a comma before every group of three digits (except at the beginning).
		if (size - i) % 3 == 0 and i > 0:
			formatted += "," + str_num[i]
		else:
			formatted += str_num[i]
	return formatted
