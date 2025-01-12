extends Node2D
## Main Menu
##
## Fades in and provides the initial interface for the game

const OPTIONS_MENU = preload("res://scenes/menus/options_menu.tscn")
const CREDITS = preload("res://scenes/menus/credits.tscn")


func _ready() -> void:
	# set the initial alpha to fully transparent
	$Contents.modulate.a = 0
	# fade the scene alpha in
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 1), 2)


func _on_credits_pressed() -> void:
	add_child(CREDITS.instantiate())


func _on_options_pressed() -> void:
	add_child(OPTIONS_MENU.instantiate())


func _on_play_pressed() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 0), 1)
	tween.tween_callback(func(): Global.goto_scene("res://scenes/game.tscn"))
