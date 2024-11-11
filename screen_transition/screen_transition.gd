extends CanvasLayer

@onready var animator: AnimationPlayer = %AnimationPlayer

var _filename := ""

func _anim_execute_swap() -> void:
	get_tree().change_scene_to_file(_filename)
	get_tree().paused = false
	_filename = ""

func reload_scene() -> void:
	change_scene_to_file(get_tree().current_scene.scene_file_path)

func change_scene_to_file(filename: String) -> void:
	visible = true

	assert(_filename == "")
	_filename = filename
	get_tree().paused = true
	animator.play("RESET")
	animator.play("transition")
	
	await animator.animation_finished

	visible = false
