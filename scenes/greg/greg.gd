extends Node2D
## Greg
##
## Snail mascot that crawls across the bottom of the credits screen

# emits when Greg leaves the viewport
signal off_screen

func _process(_delta: float) -> void:
	if $CharacterBody2D.position.x > get_viewport_rect().size.x + $SoftBody2D.texture.get_size().x:
		off_screen.emit()
		queue_free()
