extends Node2D
## Main Menu
##
## Fades in and provides the initial interface for the game

const SETTINGS_MENU = preload("res://scenes/menus/settings_menu.tscn")
const CREDITS = preload("res://scenes/menus/credits.tscn")


func _ready() -> void:
	Global.score = 0
	Global.play_music_track()
	# set the initial alpha to fully transparent then fade in
	$Contents.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 1), 1.5)
	


func _on_credits_pressed() -> void:
	$Audio/Button.play()
	add_child(CREDITS.instantiate())


func _on_settings_pressed() -> void:
	$Audio/Button.play()
	add_child(SETTINGS_MENU.instantiate())


func _on_play_pressed() -> void:
	$Audio/Button.play()
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(func(): Global.goto_scene("res://scenes/game.tscn"))
