extends Node2D


func _ready() -> void:
	# set the initial alpha to fully transparent then fade in
	$Background.modulate.a = 0
	$Contents.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Background, "modulate", Color(1, 1, 1, 1), 0.5)
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 1), 0.5)


func _on_back_pressed() -> void:
	$Audio/Dismiss.play()
	# fade out and self-destruct
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_property($Background, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(queue_free)
