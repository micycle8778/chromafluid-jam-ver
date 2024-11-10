extends Node

var _start := Time.get_ticks_msec()
var _end := -1

func reset() -> void:
	_start = Time.get_ticks_msec()
	_end = -1

func stop() -> void:
	_end = Time.get_ticks_msec()

func get_duration() -> String:
	var end := _end if _end != -1 else Time.get_ticks_msec()
	var delta := end - _start

	var hours := int(delta / (1000 * 60 * 60)) # 1000 ms * 60 s * 60 m
	var minutes := int(delta / (1000 * 60)) % 60 # 1000 ms * 60 s % 60 m
	var seconds := int(delta / 1000) % 60 # 1000 ms % 60 s
	var millis := int(delta) % 60

	return "Time: %02d:%02d:%02d.%03d" % [hours, minutes, seconds, millis]
