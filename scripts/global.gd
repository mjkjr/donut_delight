extends Node
## Global game state and scene switching

var score: int = 0
var high_score: int = 0

## Adds commas for thousands separators
func format_large_integer(num: int) -> String:
	var string: String = str(num)
	var size: int = string.length()
	var formatted: String = ""
	
	for i in range(size):
			if (
				(size - i) % 3 == 0
				and i > 0
			):
				formatted = str(formatted, ",", string[i])
			else:
				formatted = str(formatted, string[i])
	
	return formatted


## Scene Switching

var current_scene = null


func _ready() -> void:
	# the last child of the root is the current scene
	current_scene = get_tree().current_scene


## Load a new scene and delete the current one
func goto_scene(path: String) -> void:
	# Call deferred so any current scene code can complete and avoid crashing
	_deferred_goto_scene.call_deferred(path)


func _deferred_goto_scene(path: String) -> void:
	current_scene.free()
	current_scene = ResourceLoader.load(path).instantiate()
	get_tree().root.add_child(current_scene)
	
	# Set to make this compatible with the SceneTree.change_scene_to_file() API
	get_tree().current_scene = current_scene
