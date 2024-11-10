class_name MainCam extends Camera2D

static var instance: MainCam

@export var shake_noise: Noise

const WINDOW_WIDTH := 1152
const WINDOW_HEIGHT := 648 

func _init() -> void:
	instance = self

var shake_time := 0.
var shake_dir := Vector2.ZERO

@onready var parent := get_parent() as Path2D
@onready var debug_line: Line2D = %TargetLine

var desired_pos := global_position

func _ready() -> void:
	debug_line.visible = OS.has_feature("debug") and false

func _process_shake(delta: float) -> void:
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

func _process_camera_follow() -> void:
	if not parent: return

	var extents = Rect2(
		global_position,
		Vector2(WINDOW_WIDTH, WINDOW_HEIGHT) * 0.0
	)
	extents.position -= extents.size / 2

	var pos := Player.instance.global_position
	if extents.has_point(pos): return

	desired_pos = global_position
	
	if not extents.has_point(Vector2(pos.x, global_position.y)): # if the x is out of extents
		if pos.x > global_position.x: # player is too far right
			desired_pos.x += pos.x - extents.end.x
		else: # player is too far left
			desired_pos.x -= extents.position.x - pos.x

	if not extents.has_point(Vector2(global_position.x, pos.y)): # if the y is out of extents
		if pos.y > global_position.y: # player is too far down
			desired_pos.y += pos.y - extents.end.y
		else: # player is too far up
			desired_pos.y -= extents.position.y - pos.y
	
	# var p := parent.curve.get_closest_point(parent.to_local(desired_pos))
	var p := parent.curve.get_closest_point(parent.to_local(Player.instance.global_position))
	global_position = parent.to_global(p)

func _process(delta: float) -> void:
	_process_shake(delta)
	_process_camera_follow()

	debug_line.points = PackedVector2Array([Vector2.ZERO, to_local(desired_pos)])

func shake(time: float, direction: Vector2 = Vector2.ZERO) -> void:
	shake_time = time
	shake_dir = direction
