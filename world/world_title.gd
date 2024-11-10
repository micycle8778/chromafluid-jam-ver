extends CanvasLayer

@onready var label: Label = %Label

func _ready() -> void:
	label.text = "- %s -" % label.text
	var tree := get_tree()
	await tree.create_timer(2.).timeout

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "position", label.position + (Vector2.UP * 50), 0.5)
	tween.parallel().tween_property(label, "modulate", Color.TRANSPARENT, 0.3)

	await tween.finished
	queue_free()
