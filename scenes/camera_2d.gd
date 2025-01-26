class_name SFXCamera
extends Camera2D

@export_group("Camera Shake")
@export var shake_strength: float = 30
@export var shake_fade: float = 5

var current_shake: float = 0
var current_fade: float = 0


func _process(delta: float) -> void:
	if current_shake > 0.0:
		current_shake = lerpf(current_shake, 0, current_fade * delta)
		offset = Vector2(randf_range(-current_shake, current_shake), randf_range(-current_shake, current_shake))


func shake(strength: float = shake_strength, fade: float = shake_fade) -> void:
	current_shake = strength
	current_fade = fade
