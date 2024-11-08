class_name World extends Node2D

class NodePair:
	var parent: Node
	var node: Node

	func _init(n: Node) -> void:
		parent = n.get_parent()
		node = n

		parent.remove_child(n)

	func insert() -> void:
		parent.add_child(node)

signal world_swapping(otherness: bool)

static var instance: World
func _init() -> void:
	instance = self

func _ready() -> void:
	enforce_worldness()

var otherness := true

func swap_worlds() -> void:
	otherness = not otherness
	enforce_worldness()
	world_swapping.emit(otherness)

var node_pairs: Array[NodePair]
func enforce_worldness() -> void:
	var bad_group := "alt_worldly" if otherness else "other_worldly"
	var good_group := "other_worldly" if otherness else "alt_worldly"

	for n in get_tree().get_nodes_in_group(good_group):
		n.visible = true

	for np in node_pairs:
		np.insert()
		np.node.visible = true

	node_pairs.clear()
	for n in get_tree().get_nodes_in_group(bad_group):
		node_pairs.append(NodePair.new(n))

