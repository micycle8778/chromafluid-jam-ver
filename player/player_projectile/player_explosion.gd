class_name PlayerExplosion extends Sprite2D

# TODO: hurt enemies lol

func _on_aoe_area_entered(area:Area2D) -> void:
	if area.is_in_group("explodable"):
		area.explode(self)

func _on_aoe_body_entered(body:Node2D) -> void:
	if body.is_in_group("explodable"):
		body.explode(self)
