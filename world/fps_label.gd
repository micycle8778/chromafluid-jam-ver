extends Label

func _ready() -> void:
	visible = OS.has_feature("debug")

func _process(delta: float) -> void:
	text = "FPS: " + str(int(1 / delta))
