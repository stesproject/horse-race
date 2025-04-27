class_name GameManager
extends Node2D

@onready var message: Control = $"../CanvasLayer/Message/RichTextLabel"
@onready var players: Node2D = $"../Players"
@onready var phantom_camera_2d: PhantomCamera2D = $"../PhantomCamera2D"
@onready var continue_button: Button = $"../CanvasLayer/ContinueButton"

@onready var starting_area: Area2D = $"../StartingArea"
@onready var collision_starting_area = starting_area.get_child(0)
@onready var spawnArea = collision_starting_area.shape.extents
@onready var spawnAreaOrigin = collision_starting_area.global_position -  spawnArea

const HORSE = preload("res://player/player.tscn")

var keys: Array[Key]
var ready_to_start := false


func _ready() -> void:
	TweenAnim.pulse(message, 0.05, 0.3, 1)
	SignalBus.win_race.connect(stop_race)
	continue_button.pressed.connect(exit_race)


func _unhandled_input(event: InputEvent) -> void:
	var valid = event is InputEventJoypadButton or event is InputEventKey
	if valid and event.pressed:
		var key = event.button_index if event is InputEventJoypadButton else event.keycode
		if event.is_action_pressed("start"):
			if ready_to_start:
				set_process_unhandled_input(false)
				SignalBus.start_countdown.emit()
				message.get_parent().hide()
				_init_camera()
			return
		if !ready_to_start:
			message.text = "Press ENTER to start"
			TweenAnim.stop(message)
			ready_to_start = true
		if !keys.has(key):
			add_player(key, event is InputEventJoypadButton)
			keys.append(key)


func get_players_total() -> int:
	return players.get_child_count()


func add_player(key: int, is_joypad := false):
	var player: Player = HORSE.instantiate()
	players.add_child(player)
	player.setup(get_players_total(), key, is_joypad)
	player.position = get_random_point_in_area()


func get_random_point_in_area() -> Vector2:
	var x = randf_range(spawnAreaOrigin.x, spawnArea.x)
	var y = randf_range(spawnAreaOrigin.y, spawnArea.y)
	return Vector2(x, y)


func stop_race(winner: Player):
	phantom_camera_2d.follow_mode = PhantomCamera2D.FollowMode.GLUED
	phantom_camera_2d.follow_target = winner
	phantom_camera_2d.zoom = Vector2(2, 2)


func exit_race():
	var main_menu = load("res://menu/level_selection_menu.tscn")
	get_tree().call_deferred("change_scene_to_packed", main_menu)


func _init_camera():
	for player in players.get_children():
		phantom_camera_2d.append_follow_targets(player)
		
