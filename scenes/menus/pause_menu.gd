extends Node2D
## Pause Menu
##
## Fades in and displays the game's pause menu

const OPTIONS_MENU = preload("res://scenes/menus/options_menu.tscn")
const CREDITS = preload("res://scenes/menus/credits.tscn")
const LEAVE_GAME_MENU = preload("res://scenes/menus/leave_game_menu.tscn")


func _ready() -> void:
	# set the initial alpha to fully transparent
	$Contents.modulate.a = 0
	# fade the scene alpha in
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 1), 2)


# fade out and self-destruct
func _on_resume_pressed() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 0), 1)
	tween.tween_callback(queue_free)


func _on_options_pressed() -> void:
	add_child(OPTIONS_MENU.instantiate())


func _on_credits_pressed() -> void:
	add_child(CREDITS.instantiate())


func _on_leave_pressed() -> void:
	add_child(LEAVE_GAME_MENU.instantiate())
