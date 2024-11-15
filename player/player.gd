class_name Player extends CharacterBody2D

const AIR_FRICTION := 0.05
const MAX_SPEED := 900.
const JUMP_POWER := 950.
const GRAVITY := 2700.

const MOVE_ACCEL := 0.15

const HEAT_SPEED := 1.5
const HEAL_SPEED := 0.3

static var instance: Player

@export var animated := false
@export var hot_color := Color.RED

var acceleration := MOVE_ACCEL
var tween: Tween
var projectile_scene: PackedScene = preload("player_projectile/player_projectile.tscn")
var keys: Array[Key] = []
var slam_force := 0.
var shape: Shape2D 
var heaters: int = 0:
	set(v):
		assert(v >= 0)
		heaters = v
var ammo = {
	true: 3,
	false: 3
}
var health := 1.0

@onready var left_jump_detector: Area2D = %LeftJumpDetector
@onready var right_jump_detector: Area2D = %RightJumpDetector
@onready var sprite: Sprite2D = %Sprite
@onready var death_particles: CPUParticles2D = %DeathParticles

enum State {
	DEFAULT,
	SLAM,
}

var state := State.DEFAULT:
	set(v):
		_exit_state(state)
		state = v
		_enter_state(state)

var particles_tween: Tween

const SLAM_PARTICLE_SPEED = 5.

func _exit_state(s: State) -> void:
	match s:
		State.SLAM:
			if particles_tween != null: particles_tween.stop()
			Snow.particles.speed_scale = SLAM_PARTICLE_SPEED
			particles_tween = create_tween()
			particles_tween.tween_property(Snow.particles, "speed_scale", 1., 0.4)

func _enter_state(s: State) -> void:
	match s:
		State.SLAM:
			slam_force = 0
			if particles_tween != null: particles_tween.stop()
			particles_tween = create_tween()
			particles_tween.tween_property(Snow.particles, "speed_scale", SLAM_PARTICLE_SPEED, 0.1)
		_:
			pass

func use_key() -> bool:
	if keys.is_empty():
		return false

	keys.pop_back().consume()

	return true

func _init() -> void:
	instance = self

func _ready() -> void:
	shape = %CollisionShape2D.shape

func _wall_jump(dir: float) -> void:
	velocity.x += 1000. * dir

	if tween != null: tween.stop()
	acceleration = 0.
	tween = create_tween()
	tween.tween_property(self, "acceleration", MOVE_ACCEL, 0.15)

func _process_slam(delta: float) -> void:
	velocity.x = 0
	# print("[player::slam] velocity = ", velocity)
	velocity.y = max(1000, velocity.y)
	velocity.y += 20000 * delta

	move_and_slide()
	slam_force = max(slam_force, velocity.y)

	if is_on_floor():
		# print("[player::slam] slam_force = ", slam_force)
		state = State.DEFAULT

		velocity.y = -1000

		World.instance.swap_worlds()
		MainCam.instance.shake(0.1, Vector2.UP * 1.5)

func get_aim() -> Vector2:
	if ControllerManager.is_controller:
		return ControllerManager.get_joystick_aim()
	else:
		return global_position.direction_to(get_global_mouse_position())

func _process_default(delta: float) -> void:
	if Input.is_action_just_pressed("fire") and ammo[World.instance.otherness] > 0:
		var scene: Node2D = get_tree().current_scene
		var projectile: PlayerProjectile = projectile_scene.instantiate()

		projectile.position = scene.to_local(global_position)
		projectile.rotation = get_aim().angle()
		projectile.setup(get_aim() * 2000.)

		scene.add_child(projectile)
		ammo[World.instance.otherness] -= 1

	var input := Input.get_axis("move_left", "move_right")
	
	if input == 0. and not is_on_floor():
		velocity.x = lerpf(velocity.x, MAX_SPEED * signf(input), min(AIR_FRICTION, acceleration))
	else:
		velocity.x = lerpf(velocity.x, MAX_SPEED * signf(input), acceleration)

	if Input.is_action_just_pressed("jump"):
		var wall_jumped := false

		if left_jump_detector.has_overlapping_bodies() and not is_on_floor():
			# print("[player::default] wall jumping left")
			_wall_jump(1)
			wall_jumped = true

		if right_jump_detector.has_overlapping_bodies() and not is_on_floor():
			# print("[player::default] wall jumping right")
			_wall_jump(-1)
			wall_jumped = true

		if wall_jumped or is_on_floor():
			velocity.y = min(0, velocity.y)
			velocity += Vector2.UP * JUMP_POWER

	else:
		velocity += Vector2.DOWN * GRAVITY * delta

	move_and_slide()

	if Input.is_action_just_pressed("slam") and not is_on_floor():
		state = State.SLAM

func _physics_process(delta: float) -> void:
	if animated: return

	match state:
		State.DEFAULT:
			_process_default(delta)
		State.SLAM:
			_process_slam(delta)
		_:
			assert(false, "unreachable")
	
	if not was_killed:
		if Input.is_action_just_pressed("restart_level"):
			was_killed = true
			ScreenTransition.reload_scene()
		elif Input.is_action_just_pressed("restart_game") or (Input.is_action_pressed("start_button") and Input.is_action_pressed("right_bumper")):
			was_killed = true
			ScreenTransition.change_scene_to_file("uid://bc2g5tcrqoe70")

func _process(delta: float) -> void:
	if heaters > 0:
		health = move_toward(health, 0.0, HEAT_SPEED * delta)
	else:
		health = move_toward(health, 1.0, HEAL_SPEED * delta)
	
	modulate = hot_color.lerp(Color.WHITE, health)
	if health == 0.:
		kill()

var was_killed := false
func kill() -> void:
	if was_killed: return
	was_killed = true

	sprite.visible = false

	var gp := death_particles.global_position
	remove_child(death_particles)
	death_particles.position = get_tree().current_scene.to_local(gp)
	death_particles.modulate = modulate
	get_tree().current_scene.add_child(death_particles)
	death_particles.emitting = true

	MainCam.instance.shake(0.3, Vector2.ZERO, 1.5)

	await get_tree().create_timer(0.3).timeout
	ScreenTransition.reload_scene()
