extends Button

func _on_pressed() -> void:
	for node in get_tree().get_nodes_in_group("player_projectile"):
		node.visible = false

	ScreenTransition.change_scene_to_file("uid://bc2g5tcrqoe70")

