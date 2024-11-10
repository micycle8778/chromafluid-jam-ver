class_name World extends Node2D

class NodePair:
	var parent: Node
	var node: Node

	func _init(n: Node) -> void:
		parent = n.get_parent()
		node = n

		parent.remove_child(n)

	func insert() -> void:
		if node != null:
			parent.add_child(node)
			node.visible = true

signal world_swapping(otherness: bool)

static var instance: World
func _init() -> void:
	instance = self

func _ready() -> void:
	enforce_worldness()

var otherness := true

func is_safe_for_player(gp: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	query.transform = Transform2D(0., gp)
	query.collision_mask = Player.instance.collision_mask
	query.shape_rid = Player.instance.shape.get_rid()

	var results = space_state.intersect_shape(query)
	return results == []

func _point_count_of_radius(radius: float) -> int:
	if radius <= 20:
		return 8
	return 12

func unstuck_player() -> void:
	await get_tree().physics_frame
	# ensure the player doesn't get stuck
	var pos := Player.instance.global_position
	if is_safe_for_player(pos):
		return

	print("[world] unstucking player")
	for i in range(1, 100):
		var radius := i * 10.
		var points := _point_count_of_radius(radius)
		var d_theta := TAU / radius
		for j in points:
			var p := pos + (Vector2.RIGHT.rotated(d_theta * j) * radius)
			if is_safe_for_player(p):
				print("[world] moving player to ", p)
				Player.instance.global_position = p
				return
	push_error("[world] double fuck")

func swap_worlds() -> void:
	otherness = not otherness
	enforce_worldness()
	world_swapping.emit(otherness)

	unstuck_player()

var node_pairs: Array[NodePair]
func enforce_worldness() -> void:
	var bad_group := "alt_worldly" if otherness else "other_worldly"
	var good_group := "other_worldly" if otherness else "alt_worldly"

	for n in get_tree().get_nodes_in_group(good_group):
		n.visible = true

	for np in node_pairs:
		np.insert()

	node_pairs.clear()
	for n in get_tree().get_nodes_in_group(bad_group):
		node_pairs.append(NodePair.new(n))
