extends Node2D


func _ready() -> void:
	%VolumeMaster.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	%VolumeMusic.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	%VolumeEffects.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects")))
	
	# set the initial alpha to fully transparent then fade in
	$Background.modulate.a = 0
	$Contents.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Background, "modulate", Color(1, 1, 1, 1), 0.5)
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 1), 0.5)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()


func _on_back_pressed() -> void:
	$Audio/Dismiss.play()
	# fade out and self-destruct
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_property($Background, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(queue_free)


func _on_master_volume_drag_ended(value_changed: bool) -> void:
	if not value_changed: return
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(%VolumeMaster.value))


func _on_music_volume_drag_ended(value_changed: bool) -> void:
	if not value_changed: return
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(%VolumeMusic.value))


func _on_effects_volume_drag_ended(value_changed: bool) -> void:
	if not value_changed: return
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(%VolumeEffects.value))
