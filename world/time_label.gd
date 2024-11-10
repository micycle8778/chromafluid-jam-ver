extends Label

func _ready() -> void:
	text = TimeKeeper.get_duration()
