extends Node2D
## Options Menu
##
## Fades in and displays the game's options


func _ready() -> void:
	# set the initial alpha to fully transparent
	$Contents.modulate.a = 0
	# fade the scene alpha in
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 1), 2)


# fade out and self-destruct
func _on_back_pressed() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 0), 1)
	tween.tween_callback(queue_free)
