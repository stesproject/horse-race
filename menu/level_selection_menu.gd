extends Control

@export var route_button: PackedScene

@onready var route_buttons_container: GridContainer = $Panel/RouteButtonsContainer

const ROUTE_1 = preload("res://routes/route-1.tscn")
const ROUTE_2 = preload("res://routes/route-2.tscn")
const ROUTE_3 = preload("res://routes/route-3.tscn")

var routes = [
	ROUTE_1,
	ROUTE_2,
	ROUTE_3
]


func _ready() -> void:
	for i in routes.size():
		var route = routes[i]
		var button: Button = route_button.instantiate()
		button.text = str(i + 1)
		button.pressed.connect(func(): load_route(route))
		route_buttons_container.add_child(button)
		if i == 0:
			button.grab_focus()


func load_route(scene) -> void:
	get_tree().change_scene_to_packed(scene)
