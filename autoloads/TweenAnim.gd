extends Node

var node_tweens: Dictionary = {}

func pulse(node: CanvasItem, scale_amt: float = 0.05, alpha_amt: float = 0.3, duration: float = 0.6) -> void:
	var original_scale : Vector2 = node.scale
	var original_color : Color = node.modulate

	var tween := node.get_tree().create_tween()
	tween.set_loops()

	tween.tween_property(node, "scale", original_scale * (1.0 + scale_amt), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(node, "modulate:a", original_color.a * (1.0 - alpha_amt), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(node, "scale", original_scale, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(node, "modulate:a", original_color.a, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	node_tweens[node] = {
		"tween": tween,
		"scale": original_scale,
		"modulate": original_color
	}


func stop(node: CanvasItem) -> void:
	var properties = node_tweens[node]
	for property in properties:
		if property == "tween":
			var tween = properties[property]
			tween.kill()
		else:
			node[property] = properties[property]

	node_tweens.erase(node)


func punch_in(node: CanvasItem, strength: float = 0.3, duration: float = 0.15) -> void:
	var original_scale = node.scale
	var punch_in_value = original_scale * (1 + strength)
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "scale", punch_in_value, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func warp(node: Node2D, squash: Vector2 = Vector2(1.2, 0.8), duration: float = 0.2) -> void:
	var original_scale := node.scale

	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "scale", squash, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func spin(node: Node2D, revolutions: float = 1.0, duration: float = 0.5) -> void:
	var start_rotation = node.rotation_degrees
	var end_rotation = start_rotation + 360.0 * revolutions
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "rotation_degrees", end_rotation, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
