extends Node2D
## Greg
##
## Snail mascot that crawls across the bottom of the credits screen

# emits when Greg leaves the viewport
signal off_screen

const GREG_SLIME_TRAIL = preload("res://assets/greg_slime_trail.png")


func _process(_delta: float) -> void:
	if $CharacterBody2D.position.x > get_viewport_rect().size.x + (2 * $SoftBody2D.texture.get_size().x):
		off_screen.emit()
		queue_free()


func _on_slime_timer_timeout() -> void:
	var slime = Sprite2D.new()
	slime.texture = GREG_SLIME_TRAIL
	$CharacterBody2D.add_sibling(slime)
	slime.global_position = %SlimeSpawn.global_position
	var tween = slime.create_tween()
	tween.tween_interval(2.5)
	tween.tween_property(slime, "modulate", Color(1, 1, 1, 0), 5)
	tween.tween_callback(func(): slime.queue_free())
