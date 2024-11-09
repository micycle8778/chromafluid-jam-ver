extends Line2D

@onready var ray_cast: RayCast2D = $RayCast2D
func _process(_delta: float) -> void:
	var aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down").normalized()

	visible = aim != Vector2.ZERO
	if not visible:
		return

	ray_cast.target_position = aim * 10000
	ray_cast.force_raycast_update()
	var hit = to_local(ray_cast.get_collision_point()) if ray_cast.is_colliding() else ray_cast.target_position
	points = PackedVector2Array([Vector2.ZERO, hit])
