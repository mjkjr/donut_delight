extends Node
## Donut Delight
##
## A cute donut merging game

## TODO: lose condition when area is full
## TODO: Save and load high score
## TODO: Make softbody wiggle while being moved by the claw, see:
##       https://softbody2d.appsinacup.com/docs/tutorial-basics/attach-a-softbody-to-character-controller/
## TODO: Polish: tween next object into current object position
## TODO: Add proper claw graphics
## TODO: Add polish "puff" particle effect when objects merge
## TODO: Sound effects
## TODO: Background music
## TODO: Audio settings
## TODO: Polish: make escape button dismiss menus

const PAUSE_MENU = preload("res://scenes/menus/pause_menu.tscn")

const OBJECTS = [
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
const MAX_OBJECT_INDEX: int = 10

var paused: bool = false

var score = 0

var player_control_active = false

var current_item = null
var current_item_offset: Vector2

var next_item = null
var next_item_index: int
var next_item_sprite: Sprite2D = null

# keeps track of objects in play
# each element is a Dictionary with the following structure:
# { object_reference: int }
var objects: Dictionary = {}


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
	
	generate_merge_sequence_chart()
	
	# Create the initial game objects
	spawn_next_item()
	make_next_item_current()
	# NOTE: this is blocking, but it's ok here at the very beginning
	# wait a moment before giving player control
	await get_tree().create_timer(0.5).timeout
	player_control_active = true


func _process(_delta: float) -> void:
	if not player_control_active: return
	
	# Player left/right movement of the claw
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		
		# Constrain to width of play area
		var new_x = get_viewport().get_mouse_position().x
		
		if new_x < %Boundaries/Left.position.x + current_item_offset.x:
			%Claw.position.x = %Boundaries/Left.position.x + current_item_offset.x
		elif new_x > %Boundaries/Right.position.x - current_item_offset.x:
			%Claw.position.x = %Boundaries/Right.position.x - current_item_offset.x
		else:
			%Claw.position.x = new_x
		
		current_item.position.x = %Claw.position.x


func _input(event: InputEvent) -> void:
	if paused: return
	
	## FIXME: menu displays but game still running in background
	if event.is_action_pressed("back"):
		paused = true
		%UI.add_child(PAUSE_MENU.instantiate())


func _unhandled_input(event: InputEvent) -> void:
	if player_control_active and event.is_action_released("move"):
		drop_item()


# releases the held object from the claw
func drop_item() -> void:
	player_control_active = false
	current_item.get_node("SoftBody2D").gravity_scale = 1
	## FIXME: this is blocking, wait for object to fall passed upper boundary instead
	# wait a moment before giving player control
	await get_tree().create_timer(0.75).timeout
	make_next_item_current()
	player_control_active = true


func make_next_item_current() -> void:
	next_item_sprite.free()
	current_item = next_item
	current_item_offset = current_item.get_node("SoftBody2D").texture.get_size() * 0.5
	$Contents.add_child(current_item)
	objects[current_item.get_path()] = next_item_index
	current_item.position.x = %Claw.position.x
	current_item.position.y = %Claw.position.y + current_item_offset.y
	bind_softbody_collision(current_item)
	spawn_next_item()


func spawn_next_item() -> void:
	next_item_index = randi_range(0, 5)
	next_item = OBJECTS[next_item_index].instantiate()
	next_item.get_node("SoftBody2D").gravity_scale = 0
	next_item_sprite = Sprite2D.new()
	next_item_sprite.texture = next_item.get_node("SoftBody2D").texture
	next_item_sprite.scale = Vector2(0.5, 0.5)
	$Contents.add_child(next_item_sprite)
	next_item_sprite.position.x = 100
	next_item_sprite.position.y = 175


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
			
			# Increment the score
			score += 100 * (1 + object_index)
			%Score.text = str(score)


func spawn_object(index: int, position: Vector2) -> void:
	var new_object = OBJECTS[index].instantiate()
	$Contents.add_child(new_object)
	new_object.position = position
	objects[new_object.get_path()] = index
	bind_softbody_collision(new_object)
	new_object.scale = Vector2(0.1, 0.1)
	var tween = get_tree().create_tween()
	tween.tween_property(new_object, "scale", Vector2(1, 1), 0.25)
	## TODO: Add polish "puff" particle effect


func bind_softbody_collision(object: Node2D) -> void:
	for child in object.get_node("SoftBody2D").get_children():
		if child is RigidBody2D:
			child.body_entered.connect(resolve_collision.bind(child))
			child.contact_monitor = true
			child.max_contacts_reported = 1


# ATTENTION
func generate_merge_sequence_chart() -> void:
	# TODO: divide the screen width by the number of objects and scale the sprites appropriately
	# TODO: add an arrow sprite between the objects
	for i in range(OBJECTS.size()):
		var object: Node2D = OBJECTS[i].instantiate()
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = object.get_node("SoftBody2D").texture
		sprite.scale = Vector2(0.25, 0.25)
		$Contents.add_child(sprite)
		sprite.position.x = sprite.texture.get_size().x * 0.25 * i
		sprite.position.y = 1750
