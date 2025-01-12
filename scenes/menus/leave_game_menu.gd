extends Node2D
## Leave Game Menu
##
## Fades in and displays the game's leave game menu

func _ready() -> void:
	# set the initial alpha to fully transparent
	$Contents.modulate.a = 0
	# fade the scene alpha in
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 1), 2)


# fade out and self-destruct
func _on_remain_pressed() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 0), 1)
	tween.tween_callback(queue_free)


func _on_leave_pressed() -> void:
	# fade out and return to the main menu
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 0), 2)
	tween.tween_callback(func(): Global.goto_scene("res://scenes/menus/main_menu.tscn"))
