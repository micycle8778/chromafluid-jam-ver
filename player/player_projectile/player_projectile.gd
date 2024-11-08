class_name PlayerProjectile extends Node2D 

var velocity := Vector2.ZERO
var was_setup := false

@onready var otherness := World.instance.otherness
@onready var ray_cast: RayCast2D = %RayCast2D
@onready var bullet_sprite: Sprite2D = %BulletSprite
@onready var explosive_sprite: Sprite2D = %ExplosiveSprite
@onready var trail_particles: CPUParticles2D = %TrailParticles
@onready var player_detector: Area2D = %PlayerDetector
@onready var light: PointLight2D = %PointLight2D

var explosion_scene: PackedScene = preload("player_explosion.tscn")

func _on_world_swapping(o: bool) -> void:
	bullet_sprite.visible = false
	player_detector.monitoring = true
	light.visible = otherness != o
	explosive_sprite.visible = true

	velocity = Vector2.ZERO

	if otherness == o:
		await get_tree().physics_frame
		queue_free()


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
		print("[player_projectile] exploding!")
		var scene: Node2D = get_tree().current_scene
		var explosion: PlayerExplosion = explosion_scene.instantiate()
		explosion.position = scene.to_local(global_position)
		scene.add_child(explosion)

		# TODO: explosion on the ground don't push the player enough
		var from_player := global_position.direction_to(player.global_position)
		MainCam.instance.shake(0.2, from_player * 2)
		player.velocity.y = 0
		player.velocity += from_player * 1750.
		queue_free()

