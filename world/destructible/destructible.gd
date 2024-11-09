extends StaticBody2D

@onready var particles: CPUParticles2D = %Particles
@onready var sprite: Sprite2D = %Sprite

func explode(explosion: PlayerExplosion) -> void:
	collision_layer = 0
	sprite.visible = false

	var scene: Node2D = get_tree().current_scene
	var gp := particles.global_position

	remove_child(particles)
	particles.position = scene.to_local(gp)
	particles.rotation = explosion.global_position.direction_to(global_position).angle()
	# WARN: we're assuming we're in a world tilemap here, which is a pretty safe assumption
	particles.modulate = get_parent().modulate 

	scene.add_child(particles)
	particles.emitting = true
	
	var tilemap: TileMapLayer = get_parent()
	if tilemap:
		tilemap.set_cell(tilemap.local_to_map(position))
