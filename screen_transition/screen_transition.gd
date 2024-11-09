extends CanvasLayer

@onready var animator: AnimationPlayer = %AnimationPlayer

var _filename := ""

func _anim_execute_swap() -> void:
	get_tree().change_scene_to_file(_filename)
	get_tree().paused = false

func change_scene_to_file(filename: String) -> void:
	assert(_filename == "")
	_filename = filename
	get_tree().paused = true
	animator.play("transition")
	
	await animator.animation_finished
	_filename = ""
