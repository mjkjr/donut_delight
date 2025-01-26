extends Node2D
## Main Menu
##
## Fades in and provides the initial interface for the game

const OPTIONS_MENU = preload("res://scenes/menus/options_menu.tscn")
const CREDITS = preload("res://scenes/menus/credits.tscn")


func _ready() -> void:
	# set the initial alpha to fully transparent then fade in
	$Contents.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 1), 1.5)
	Global.play_music_track()


func _on_credits_pressed() -> void:
	$Audio/Button.play()
	add_child(CREDITS.instantiate())


func _on_options_pressed() -> void:
	$Audio/Button.play()
	add_child(OPTIONS_MENU.instantiate())


func _on_play_pressed() -> void:
	$Audio/Button.play()
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(func(): Global.goto_scene("res://scenes/game.tscn"))
