extends Node2D

const GREG = preload("res://scenes/greg/greg.tscn")

var greg_spawn_position: Vector2


func _ready() -> void:
	# set the initial alpha to fully transparent then fade in
	$Background.modulate.a = 0
	$Contents.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Background, "modulate", Color(1, 1, 1, 1), 0.5)
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 1), 0.5)
	# save Greg's spawn position
	greg_spawn_position = $Contents/Greg.position
	if get_tree().paused:
		$Contents/Greg.position.x = 1000
	else:
		$Contents/Greg/SlimeTimer.start()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		get_viewport().set_input_as_handled()
		_on_dismiss_pressed()


func _on_dismiss_pressed() -> void:
	$Audio/Button.play()
	# fade out and self-destruct
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_property($Background, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(queue_free)


func _on_greg_off_screen() -> void:
	var greg = GREG.instantiate()
	greg.off_screen.connect(_on_greg_off_screen)
	greg.position = greg_spawn_position
	$Contents.add_child(greg)
	greg.get_node("SlimeTimer").start()
