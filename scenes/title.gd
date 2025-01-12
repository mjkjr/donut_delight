extends Node2D
## Title Screen
##
## Fades in and out then switches to the main menu

func _ready() -> void:
	# set the initial alpha to fully transparent
	$Contents.modulate.a = 0
	# fade the scene alpha in then back out
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 1), 2)
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 0), 2)
	tween.tween_callback(func(): Global.goto_scene("res://scenes/menus/main_menu.tscn"))
