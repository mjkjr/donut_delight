extends Node
## Global game state and scene switching

signal screen_shake_factor_changed(new_value: float)

# Audio
const MUSIC_TRACK = preload("res://assets/audio/music/Lofi hip hop Volume 1) - 06 - Soft Lights (Loop Version).mp3")
var music: AudioStreamPlayer = null

# Tutorial
var tutorial_shown: bool = false

# Scoring
var score: int = 0
var high_score: int = 0

# Screen shake dampen factor
var screen_shake_factor: float = 1.0:
	set(value):
		screen_shake_factor = snapped(clampf(value, 0.0, 1.0), 0.1)
		screen_shake_factor_changed.emit(screen_shake_factor)

# Screen flash enabled/disabled setting
var screen_flash_enabled: bool = true

# Scene management
var current_scene = null


func _ready() -> void:
	# the last child of the root is the current scene
	current_scene = get_tree().current_scene
	
	load_settings()
	
	# prepare the music stream
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	music.stream = MUSIC_TRACK
	music.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music)


func save_settings() -> void:
	var file = FileAccess.open("user://settings", FileAccess.WRITE)
	if file != null:
		## format:
		## master volume, music volue, effects volume, screen shake factor, high_score
		var settings = PackedStringArray(
			[
				str(snapped(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))), 0.01)),
				str(snapped(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))), 0.01)),
				str(snapped(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects"))), 0.01)),
				str(screen_shake_factor),
				str(screen_flash_enabled),
				str(high_score)
			]
		)
		file.store_csv_line(settings)


func load_settings() -> void:
	var file = FileAccess.open("user://settings", FileAccess.READ)
	if file != null:
		## format:
		## master volume, music volue, effects volume, screen shake factor, screen flash enabled, high_score
		var settings = file.get_csv_line()
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(float(settings[0])))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(float(settings[1])))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(float(settings[2])))
		screen_shake_factor = float(settings[3])
		if settings[4] == "true":
			screen_flash_enabled = true
		else:
			screen_flash_enabled = false
		high_score = int(settings[5])
	else:
		# set default bus volumes
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(0.5))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(0.5))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(0.5))


func play_music_track() -> void:
	if not music.playing:
		music.play()


## Load a new scene and delete the current one
func goto_scene(path: String) -> void:
	# Call deferred so any current scene code can complete and avoid crashing
	_deferred_goto_scene.call_deferred(path)


func _deferred_goto_scene(path: String) -> void:
	current_scene.free()
	current_scene = ResourceLoader.load(path).instantiate()
	get_tree().root.add_child(current_scene)
	
	# Set to make this compatible with the SceneTree.change_scene_to_file() API
	get_tree().current_scene = current_scene


## Adds commas for thousands separators
func format_large_integer(num: int) -> String:
	var string: String = str(num)
	var size: int = string.length()
	var formatted: String = ""
	
	for i in range(size):
			if (
				(size - i) % 3 == 0
				and i > 0
			):
				formatted = str(formatted, ",", string[i])
			else:
				formatted = str(formatted, string[i])
	
	return formatted
