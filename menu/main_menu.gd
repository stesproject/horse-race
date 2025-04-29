extends Control

@onready var button_local: Button = $Panel/VBoxContainer/ButtonLocal

func _ready() -> void:
	button_local.grab_focus()


func _on_button_local_pressed() -> void:
	_go_to_level_selection()


func _on_button_join_pressed() -> void:
	Globals.create_client()
	_go_to_level_selection()


func _on_button_host_pressed() -> void:
	Globals.create_server()
	_go_to_level_selection()


func _go_to_level_selection() -> void:
	var level_selection_menu = load("res://menu/level_selection_menu.tscn")
	get_tree().change_scene_to_packed(level_selection_menu)
