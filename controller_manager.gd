# https://github.com/gmuGADIG/FetchQuest/blob/dacaf5f3335b9602983aa1c618265068f0900496/autoloads/controller_manager.gd
extends Node

## Keeps track of the last used input device.

## The different types of input devices the user can use
enum ControlMode {
	KEYBOARD_MODE, 
	CONTROLLER_MODE
}

## If true, then the player is using a controller
var is_controller := false

## On controller, if the aim stick isn't held in any direction, the last non-zero aim will be used
var _last_nonzero_joystick_aim := Vector2.RIGHT

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouse:
		is_controller = false
		return
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		is_controller = true

func _process(_delta: float) -> void:
	var current_aim := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down").normalized()
	if current_aim != Vector2.ZERO:
		_last_nonzero_joystick_aim = current_aim

## Only used for controllers. Returns the normalized aim direction.
## If no direction is held, returns the last direction that was held previously.
func get_joystick_aim() -> Vector2:
	return _last_nonzero_joystick_aim.normalized()
