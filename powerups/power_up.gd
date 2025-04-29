class_name PowerUp
extends Node2D

@export var duration: float = 3.0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		apply_powerup(body)
		queue_free()


func apply_powerup(_player: Player):
	pass
	
