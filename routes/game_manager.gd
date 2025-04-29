class_name GameManager
extends Node2D

@onready var message: Control = $"../CanvasLayer/Message/RichTextLabel"
@onready var players: Node2D = $"../Players"
@onready var phantom_camera_2d: PhantomCamera2D = $"../PhantomCamera2D"
@onready var continue_button: Button = $"../CanvasLayer/ContinueButton"
@onready var countdown: Control = $"../CanvasLayer/Countdown"

@onready var starting_area: Area2D = $"../StartingArea"
@onready var collision_starting_area = starting_area.get_child(0)
@onready var spawnArea = collision_starting_area.shape.extents
@onready var spawnAreaOrigin = collision_starting_area.global_position -  spawnArea
@onready var multiplayer_spawner: MultiplayerSpawner = $"../MultiplayerSpawner"

const HORSE = preload("res://player/player.tscn")

var keys: Array[Key]
var ready_to_start := false


func _ready() -> void:
	await countdown.ready
	if multiplayer.get_peers().size() > 0 or multiplayer.is_server():
		_init_multiplayer_game()
	elif !Globals.online_game:
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
			var player = add_player(key, key, event is InputEventJoypadButton)
			if player:
				players.add_child(player)
				keys.append(key)


func _init_multiplayer_game():
	await multiplayer_spawner.ready
	if multiplayer.get_peers().size() == 0:
		await multiplayer.peer_connected
	multiplayer_spawner.spawn_function = add_player
	for id in multiplayer.get_peers():
		multiplayer_spawner.spawn(id)
	multiplayer_spawner.spawn(multiplayer.get_unique_id())
	start_race()


func get_players_total() -> int:
	return players.get_child_count()


func add_player(player_id: int, key: int = KEY_1, is_joypad := false):
	var player: Player = HORSE.instantiate()
	player.call_deferred("setup", player_id, key, is_joypad)
	player.position = get_random_point_in_area()
	return player


func get_random_point_in_area() -> Vector2:
	var x = randf_range(spawnAreaOrigin.x, spawnArea.x)
	var y = randf_range(spawnAreaOrigin.y, spawnArea.y)
	return Vector2(x, y)


func start_race():
	set_process_unhandled_input(false)
	SignalBus.start_countdown.emit()
	message.get_parent().hide()
	_init_camera()


func stop_race(winner: Player):
	phantom_camera_2d.follow_mode = PhantomCamera2D.FollowMode.GLUED
	phantom_camera_2d.follow_target = winner
	phantom_camera_2d.zoom = Vector2(2, 2)


func exit_race():
	var main_menu = load("res://menu/main_menu.tscn")
	get_tree().change_scene_to_packed(main_menu)


func _init_camera():
	for player in players.get_children():
		phantom_camera_2d.append_follow_targets(player)
		
