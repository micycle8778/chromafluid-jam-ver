extends Parallax2D

@onready var particles: CPUParticles2D = %Particles

func _on_node_added(node: Node) -> void:
	if get_tree().current_scene == node:
		visible = node is World

		if particles != null:
			particles.speed_scale = 1.

# just fast enough: this should call before the first scene's _ready
func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)
