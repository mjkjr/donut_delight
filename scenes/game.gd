extends Node
## Game
##
## Fades in and starts the game

const DONUTS = [
	preload("res://scenes/donuts/donut01.tscn"),
	preload("res://scenes/donuts/donut02.tscn"),
	preload("res://scenes/donuts/donut03.tscn"),
	preload("res://scenes/donuts/donut04.tscn"),
	preload("res://scenes/donuts/donut05.tscn"),
	preload("res://scenes/donuts/donut06.tscn"),
	preload("res://scenes/donuts/donut07.tscn"),
	preload("res://scenes/donuts/donut08.tscn"),
	preload("res://scenes/donuts/donut09.tscn"),
	preload("res://scenes/donuts/donut10.tscn"),
	preload("res://scenes/donuts/donut11.tscn"),
]

var player_control_active = false
var current_item = null
var current_item_offset: Vector2
var next_item = null
var next_item_sprite: Sprite2D = null


func _ready() -> void:
	# set the initial alpha to fully transparent
	$Contents.modulate.a = 0
	# fade the scene alpha in
	var tween = get_tree().create_tween()
	tween.tween_property($Contents, "modulate", Color(1, 1, 1, 1), 2)
	# fade the UI in
	tween.set_parallel()
	$Contents/UI/MarginContainer.modulate.a = 0
	tween.tween_property($Contents/UI/MarginContainer, "modulate", Color(1, 1, 1, 1), 2)
	
	spawn_next_item()
	make_next_item_current()
	await get_tree().create_timer(1.0).timeout
	player_control_active = true


func _process(_delta: float) -> void:
	if not player_control_active: return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Constrain to width of play area
		var new_x = get_viewport().get_mouse_position().x
		if new_x < %Boundaries/Left.position.x + current_item_offset.x:
			%Claw.position.x = %Boundaries/Left.position.x + current_item_offset.x
			current_item.position.x = %Claw.position.x - current_item_offset.x
		elif new_x > %Boundaries/Right.position.x - current_item_offset.x:
			%Claw.position.x = %Boundaries/Right.position.x - current_item_offset.x
			current_item.position.x = %Claw.position.x - current_item_offset.x
		else:
			%Claw.position.x = new_x
			current_item.position.x = %Claw.position.x - current_item_offset.x


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("move"):
		## FIXME: Avoid multi-click collisions
		drop_item()


func drop_item() -> void:
	player_control_active = false
	current_item.gravity_scale = 1
	await get_tree().create_timer(1.0).timeout
	make_next_item_current()
	player_control_active = true


func spawn_next_item() -> void:
	next_item = DONUTS[randi_range(0, 5)].instantiate()
	next_item.gravity_scale = 0
	next_item_sprite = Sprite2D.new()
	next_item_sprite.texture = next_item.texture
	next_item_sprite.scale = Vector2(0.5, 0.5)
	$Contents.add_child(next_item_sprite)
	next_item_sprite.position.x = 100
	next_item_sprite.position.y = 175


func make_next_item_current() -> void:
	next_item_sprite.free()
	current_item = next_item
	current_item_offset = current_item.texture.get_size() * 0.5
	$Contents.add_child(current_item)
	current_item.position.x = %Claw.position.x - current_item_offset.x
	current_item.position.y = %Claw.position.y
	spawn_next_item()
