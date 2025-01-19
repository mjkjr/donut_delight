extends CharacterBody2D
## Greg's movement

const SPEED = 300.0

var move: bool = false


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if move:
		velocity.x = SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()


func _on_move_timer_timeout() -> void:
	move = true
	get_tree().create_timer(0.25).timeout.connect(func(): move = false)
