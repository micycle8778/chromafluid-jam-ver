class_name Key extends Area2D

var clock := 0.

@onready var starting_position := position

enum State {
	DEFAULT,
	COLLECTED,
	CONSUMED
}

var state := State.DEFAULT

func _process_default(delta: float) -> void:
	clock += delta * 2
	position = starting_position + Vector2(0, sin(clock) * 20)

func _process_collected() -> void:
	global_position = lerp(global_position, Player.instance.global_position, 0.1)

func _physics_process(delta: float) -> void:
	match state:
		State.DEFAULT:
			_process_default(delta)
		State.COLLECTED:
			_process_collected()
		State.CONSUMED:
			pass
		_:
			assert(false, "unreachable")

func consume() -> void:
	state = State.CONSUMED
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)

	await tween.finished
	queue_free()

func _on_body_entered(body:Node2D) -> void:
	if state != State.DEFAULT: return
	var player: Player = body
	if player:
		state = State.COLLECTED
		player.keys.push_back(self)
		create_tween().tween_property(self, "scale", scale * 0.7, 0.5)

