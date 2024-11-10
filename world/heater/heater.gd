extends Node2D

@onready var particles: CPUParticles2D = %Particles

func _ready() -> void:
	particles.preprocess = randf()
	particles.emitting = true

func _on_player_detector_body_exited(body:Node2D) -> void:
	var player := body as Player
	if player:
		player.heaters -= 1

func _on_player_detector_body_entered(body:Node2D) -> void:
	var player := body as Player
	if player:
		player.heaters += 1

