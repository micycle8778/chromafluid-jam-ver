class_name PlayerProjectile extends Node2D 

var velocity := Vector2.ZERO
var was_setup := false

@onready var otherness := World.instance.otherness
@onready var ray_cast: RayCast2D = %RayCast2D
@onready var bullet_sprite: Sprite2D = %BulletSprite
@onready var explosive_sprite: Sprite2D = %ExplosiveSprite
@onready var trail_particles: CPUParticles2D = %TrailParticles
@onready var player_detector: Area2D = %PlayerDetector

var explosion_scene: PackedScene = preload("player_explosion.tscn")

func _on_world_swapping(o: bool) -> void:
	if otherness == o:
		queue_free()

	bullet_sprite.visible = false
	explosive_sprite.visible = otherness != o
	player_detector.monitoring = otherness != o

	velocity = Vector2.ZERO

func setup(new_velocity: Vector2) -> void:
	velocity = new_velocity
	was_setup = true

func _ready() -> void:
	assert(was_setup)
	World.instance.world_swapping.connect(_on_world_swapping)

func _process(delta: float) -> void:
	if velocity == Vector2.ZERO: return

	ray_cast.target_position = velocity.length() * delta * Vector2.RIGHT
	ray_cast.force_raycast_update()

	if ray_cast.is_colliding():
		global_position = ray_cast.get_collision_point()
		velocity = Vector2.ZERO
		trail_particles.emitting = false
	else:
		position += velocity * delta

func _exit_tree() -> void:
	Player.instance.ammo[otherness] += 1


func _on_player_detector_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player:
		var scene: Node2D = get_tree().current_scene
		var explosion: PlayerExplosion = explosion_scene.instantiate()
		explosion.position = scene.to_local(global_position)
		scene.add_child(explosion)

		# TODO: explosion on the ground don't push the player enough
		player.velocity.y = 0
		player.velocity += global_position.direction_to(player.global_position) * 1750.
		queue_free()

