extends Node

func _on_node_added(node: Node) -> void:
	if node is PlayerProjectile:
		node.visible = false

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
