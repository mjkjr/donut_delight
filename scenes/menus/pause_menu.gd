extends Node2D

signal resume

const SETTINGS_MENU = preload("res://scenes/menus/settings_menu.tscn")
const CREDITS = preload("res://scenes/menus/credits.tscn")
const WHY_NO_ADS = preload("res://scenes/menus/why_no_ads.tscn")
const LEAVE_GAME_MENU = preload("res://scenes/menus/leave_game_menu.tscn")


func _ready() -> void:
	# set the initial alpha to fully transparent then fade in
	$Background.modulate.a = 0
	$Contents.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Background, "modulate", Color(1, 1, 1, 1), 0.25)
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 1), 0.25)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		get_viewport().set_input_as_handled()
		_on_resume_pressed()


func _on_resume_pressed() -> void:
	$Audio/Button.play()
	# fade out and self-destruct
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 0), 0.25)
	tween.tween_property($Background, "modulate", Color(1, 1, 1, 0), 0.25)
	tween.tween_callback(
		func():
			resume.emit()
			queue_free()
	)


func _on_settings_pressed() -> void:
	$Audio/Button.play()
	add_child(SETTINGS_MENU.instantiate())


func _on_credits_pressed() -> void:
	$Audio/Button.play()
	add_child(CREDITS.instantiate())


func _on_leave_pressed() -> void:
	$Audio/Button.play()
	add_child(LEAVE_GAME_MENU.instantiate())


func _on_why_no_ads_pressed() -> void:
	$Audio/Button.play()
	add_child(WHY_NO_ADS.instantiate())
