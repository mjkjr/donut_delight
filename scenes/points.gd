extends Node2D


func _ready() -> void:
	$AnimationPlayer.play("score")


func set_score(score: int) -> void:
	$Label.text = str(score)


func _set_pivot() -> void:
	$Label.pivot_offset = $Label.size * 0.5


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
