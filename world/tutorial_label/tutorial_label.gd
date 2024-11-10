extends Area2D

signal _player_entered

var dead := false
@onready var label: Label = %Label
@onready var text := label.text

func _on_world_swapping(_otherness: bool) -> void:
	print("[tutorial_label] world swapping!")
	if label.text != "":
		queue_free()

func _ready() -> void:
	var tree := get_tree()
	World.instance.world_swapping.connect(_on_world_swapping)

	label.text = ""
	await _player_entered

	for c in text:
		label.text += c
		await tree.create_timer(0.03).timeout

	await tree.create_timer(1.).timeout
	
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.)
	await tween.finished
	queue_free()

func _on_body_entered(body:Node2D) -> void:
	if body is Player:
		_player_entered.emit()

