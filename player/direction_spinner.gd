extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var direction_marker: Marker2D = $Marker2D/DirectionMarker


func enable():
	show()
	animation_player.play("spin")


func disable():
	hide()
	animation_player.stop()


func get_direction():
	return global_position.direction_to(direction_marker.global_position).normalized()
