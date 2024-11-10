@tool
class_name TransitionArea extends Area2D

@export var instant := true
@export var target_scene: String:
	set(v):
		target_scene = v
		update_configuration_warnings()

@onready var sprite: Sprite2D = %Sprite
@onready var starting_modulate = sprite.modulate

func _get_configuration_warnings() -> PackedStringArray:
	var result = []

	if target_scene == "" or load(target_scene) is not PackedScene:
		result.push_back("target_scene is not set to a valid scene!")

	return PackedStringArray(result)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	assert(target_scene != "", "target_scene was not set!")
	assert(load(target_scene) is PackedScene, "target_scene is not a valid scene!")

var clock := PI / 2.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	clock += delta
	sprite.modulate = starting_modulate * remap(sin(clock), -1, 1, 0.3, 1)

func _on_body_entered(body:Node2D) -> void:
	var player: Player = body
	if player:
		assert(instant) # TODO:
		if Player.instance != null:
			Player.instance.visible = false
		ScreenTransition.change_scene_to_file(target_scene)
