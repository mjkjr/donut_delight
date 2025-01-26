extends Node2D


func _ready() -> void:
	%FinalScore.text = Global.format_large_integer(Global.score)
	# set the initial alpha to fully transparent then fade in
	$Background.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Background, "modulate", Color(1, 1, 1, 1), 0.1)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		get_viewport().set_input_as_handled()
		_on_dismiss_pressed()


func _on_dismiss_pressed() -> void:
	$Audio/Button.play()
	# fade out and return to main menu
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_property($Black, "modulate", Color(1, 1, 1, 1), 0.5)
	tween.tween_callback(
		func():
			get_tree().paused = false
			Global.score = 0
			Global.goto_scene("res://scenes/menus/main_menu.tscn")
	)
