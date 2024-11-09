class_name LockedDoor extends StaticBody2D

func unlock() -> void:
	collision_layer = 0
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.)

	await tween.finished
	queue_free()

func _on_player_detector_body_entered(body:Node) -> void:
	var player: Player = body
	if player and player.use_key():
		unlock()
