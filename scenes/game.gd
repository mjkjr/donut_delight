extends Node
## Donut Delight
##
## A cute donut merging game

## BUGS
## CRITICAL BUG: merging sometimes causes softbody blob (more common in web version)

## MENUS
## TODO: Improve buttons color scheme (in theme)
## TODO: Improve slider color scheme (in theme)

## SCORING
## TODO: Add floating numbers upon scoring

## MISC / POLISH
## TODO: Add a losing audio sound effect
## TODO: Add "puff" particle effect when objects merge
## TODO: Spawn trail behind snail on credits screen

## PRE-RELEASE
## ATTENTION: Add "Why No Ads?" screen to menu
## ATTENTION: Add art to title screen
## ATTENTION: Update icon
## TODO: Take screen shots
## TODO: Organize license files


const PAUSE_MENU = preload("res://scenes/menus/pause_menu.tscn")
const GAME_OVER_MENU = preload("res://scenes/menus/game_over_menu.tscn")

const OBJECTS = [
	preload("res://scenes/donuts/donut01.tscn"),
	preload("res://scenes/donuts/donut02.tscn"),
	preload("res://scenes/donuts/donut09.tscn"),
	preload("res://scenes/donuts/donut10.tscn"),
	preload("res://scenes/donuts/donut07.tscn"),
	preload("res://scenes/donuts/donut08.tscn"),
	preload("res://scenes/donuts/donut04.tscn"),
	preload("res://scenes/donuts/donut05.tscn"),
	preload("res://scenes/donuts/donut06.tscn"),
	preload("res://scenes/donuts/donut03.tscn"),
	preload("res://scenes/donuts/donut11.tscn"),
]
const MAX_OBJECT_INDEX: int = 10


var high_score_set: bool = false

var game_over: bool = false

var player_control_active: bool = false

var current_item: Node2D = null
var current_item_offset: Vector2

var next_item: Node2D = null
var next_item_index: int

# keeps track of objects in play
# each element is a Dictionary with the following structure:
# { object_reference: int }
var objects: Dictionary = {}


func _ready() -> void:
	if not Global.tutorial_shown:
		%Tutorial.visible = true
	
	# set the initial alpha to fully transparent
	$Contents.modulate.a = 0
	$Contents/UI/MarginContainer.modulate.a = 0
	
	%HighScore.text = Global.format_large_integer(Global.high_score)
	
	# fade the scene alpha in
	var tween = $Contents.create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 1), 0.5)
	tween.parallel()
	# fade the UI in
	tween.tween_property($Contents/UI/MarginContainer, "modulate", Color(1, 1, 1, 1), 2)
	
	# Create the initial game objects
	spawn_next_item()
	# NOTE: this is blocking, but it's ok here at the very beginning
	# wait a moment before giving player control
	await get_tree().create_timer(0.5).timeout
	make_next_item_current()


func _process(_delta: float) -> void:
	if not player_control_active: return
	
	# Player left/right movement
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		move()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		get_viewport().set_input_as_handled()
		_show_pause_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("drop"):
		if player_control_active:
			move()
			drop_item()
		if %Tutorial.visible == true:
			if %Tutorial/Part1.visible == true:
				%Tutorial/AnimationPlayer.play("part1")
			elif %Tutorial/Part2.visible == true:
				%Tutorial/AnimationPlayer.seek(%Tutorial/AnimationPlayer.current_animation_length)
			elif %Tutorial/Part3.visible == true:
				%Tutorial/AnimationPlayer.seek(%Tutorial/AnimationPlayer.current_animation_length)


func move() -> void:
	# Constrain to width of play area
	var bounded_x = get_viewport().get_mouse_position().x
	
	if bounded_x < %Boundaries/Left.position.x + current_item_offset.x:
		bounded_x = %Boundaries/Left.position.x + current_item_offset.x
	elif bounded_x > %Boundaries/Right.position.x - current_item_offset.x:
		bounded_x = %Boundaries/Right.position.x - current_item_offset.x
	
	var tween = current_item.create_tween()
	tween.tween_property(%Spawner, "position:x", bounded_x, 0.25)
	tween.parallel().tween_property(current_item, "position:x", bounded_x, 0.25)


func drop_item() -> void:
	player_control_active = false
	%Boundaries/Top.monitoring = false
	current_item.get_node("SoftBody2D").gravity_scale = 1
	$Audio/Drop.play()
	var tween = %Spawner.create_tween()
	tween.tween_property(%Spawner, "modulate", Color(1, 1, 1, 0), 0.25)
	tween.tween_interval(1)
	tween.tween_callback(
		func():
			%Boundaries/Top.monitoring = true
			make_next_item_current()
	)
	tween.tween_property(%Spawner, "modulate", Color(1, 1, 1, 1), 0.25)


func make_next_item_current() -> void:
	current_item = next_item
	current_item_offset = current_item.get_node("SoftBody2D").texture.get_size() * 0.5
	%Gameplay.add_child(current_item)
	objects[current_item.get_path()] = next_item_index
	current_item.position.x = %Spawner.position.x
	current_item.position.y = 250
	bind_softbody_collision(current_item)
	var tween = current_item.create_tween()
	tween.tween_property(current_item, "scale", Vector2(2, 2), 0)
	tween.tween_property(current_item, "scale", Vector2(1, 1), 0.25)
	tween.tween_callback(func(): player_control_active = true)
	spawn_next_item()


func spawn_next_item() -> void:
	next_item_index = randi_range(0, 5)
	next_item = OBJECTS[next_item_index].instantiate()
	next_item.get_node("SoftBody2D").gravity_scale = 0
	%Next.texture = next_item.get_node("SoftBody2D").texture


func spawn_object(index: int, position: Vector2) -> void:
	$Audio/Merge.play()
	var new_object = OBJECTS[index].instantiate()
	%Gameplay.add_child(new_object)
	objects[new_object.get_path()] = index
	new_object.position = position
	bind_softbody_collision(new_object)
	var tween = new_object.create_tween()
	tween.tween_property(new_object, "scale", Vector2(0.05, 0.05), 0)
	tween.tween_property(new_object, "scale", Vector2(1, 1), 0.2)


func bind_softbody_collision(object: Node2D) -> void:
	for child in object.get_node("SoftBody2D").get_children():
		if child is RigidBody2D:
			child.body_entered.connect(resolve_collision.bind(child))
			child.contact_monitor = true
			child.max_contacts_reported = 1


func resolve_collision(object1: Node, object2: Node) -> void:
	# ignore self-collisions
	if object1.owner == object2.owner: return
	
	if (
			objects.has(object1.owner.get_path())
			and objects.has(object2.owner.get_path())
	):
		
		# Check that the objects are the same in the sequence
		if objects[object1.owner.get_path()] == objects[object2.owner.get_path()]:
			var object_index = objects[object1.owner.get_path()]
			
			# Check that the objects aren't the last in the sequence
			if object_index == MAX_OBJECT_INDEX: return
			
			# Get a point between the merging objects for spawning the next one
			var new_object_position: Vector2 = object1.get_parent().get_bones_center_position().lerp(object2.get_parent().get_bones_center_position(), 0.5)
			
			# Remove the merging objects from the dictonary
			objects.erase(object1.owner.get_path())
			objects.erase(object2.owner.get_path())
			
			# Free the merging objects
			object1.owner.queue_free()
			object2.owner.queue_free()
			
			# Spawn the new object
			call_deferred("spawn_object", object_index + 1, new_object_position)
			
			$Camera2D.shake(Global.screen_shake_factor)
			
			# Increment the score
			Global.score += 100 * (1 + object_index)
			%Score.text = Global.format_large_integer(Global.score)
			
			if Global.score > Global.high_score:
				Global.high_score = Global.score
				%Score.text = Global.format_large_integer(Global.high_score)
				
				# Batch save settings to avoid constantly writing to file
				if %BatchSaveTimer.is_stopped():
					%BatchSaveTimer.start()
				
				# Only play high score effect once
				if not high_score_set:
					high_score_set = true
					
					$Audio/HighScore.play()
					
					if Global.screen_flash_enabled:
						%HighScoreEffect/AnimationPlayer.play("high_score_effect")
					else:
						%HighScoreEffect/AnimationPlayer.play("high_score_effect_no_flash")


# detect game over condition
func _on_top_body_entered(body: Node2D) -> void:
	if not game_over:
		game_over = true
		# hide current item
		current_item.visible = false
		%Spawner.visible = false
		# highlight the losing object
		body.get_parent().modulate = Color(1, 0, 0, 1)
		pause_gameplay()
		Global.save_settings()
		var game_over_menu = GAME_OVER_MENU.instantiate()
		%UI.add_child(game_over_menu)


func pause_gameplay() -> void:
	# Manually save settings
	%BatchSaveTimer.stop()
	_on_batch_save_timer_timeout()
	get_tree().paused = true


func unpause_gameplay() -> void:
	get_tree().paused = false


func _on_batch_save_timer_timeout() -> void:
	Global.save_settings()


func _shake_on_high_score() -> void:
	$Camera2D.shake(Global.screen_shake_factor, 300, 3)


func _show_pause_menu() -> void:
	pause_gameplay()
	var pause_menu = PAUSE_MENU.instantiate()
	%UI.add_child(pause_menu)
	pause_menu.resume.connect(unpause_gameplay)


func _on_settings_button_pressed() -> void:
	_show_pause_menu()


func _on_tutorial_completed(part: int) -> void:
	match part:
		1:
			%Tutorial/AnimationPlayer.play("part2")
		2:
			%Tutorial/AnimationPlayer.play("part3")
		3:
			Global.tutorial_shown = true
