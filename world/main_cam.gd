class_name MainCam extends Camera2D

static var instance: MainCam

@export var shake_noise: Noise

func _init() -> void:
	instance = self

var shake_time := 0.
var shake_dir := Vector2.ZERO

func _process(delta: float) -> void:
	shake_time -= delta
	shake_time = max(0, shake_time)

	var shake_offset := Vector2.ZERO
	if shake_time > 0.:
		var t := shake_time * 100;
		shake_offset = Vector2(
			shake_noise.get_noise_1d(t),
			shake_noise.get_noise_1d(t + 1.)
		) + shake_dir
	else:
		shake_offset = Vector2.ZERO
	
	offset = shake_offset * 4.

func shake(time: float, direction: Vector2 = Vector2.ZERO) -> void:
	shake_time = time
	shake_dir = direction
