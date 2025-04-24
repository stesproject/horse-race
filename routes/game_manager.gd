class_name GameManager
extends Node2D

@onready var message: Control = $"../CanvasLayer/Message/RichTextLabel"
@onready var players: Node2D = $"../Players"
@onready var starting_positions: Node2D = $"../StartingPositions"
@onready var phantom_camera_2d: PhantomCamera2D = $"../PhantomCamera2D"

const HORSE = preload("res://player/player.tscn")

var keys: Array[Key]
var ready_to_start := false


func _ready() -> void:
	TweenAnimator.glow_pulse(message, 0.05, 0.3, 1)
	SignalBus.win_race.connect(stop_race)



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
			TweenAnimator.glow_pulse(message)
			ready_to_start = true
		if !keys.has(key):
			add_player(key, event is InputEventJoypadButton)
			keys.append(key)


func get_players_total() -> int:
	return players.get_child_count()


func add_player(key: int, is_joypad := false):
	if get_players_total() >= starting_positions.get_child_count() - 1:
		return
	var player: Player = HORSE.instantiate()
	players.add_child(player)
	player.setup(get_players_total(), key, is_joypad)
	player.position = starting_positions.get_child(get_players_total()).position


func stop_race(winner: Player):
	phantom_camera_2d.follow_mode = PhantomCamera2D.FollowMode.GLUED
	phantom_camera_2d.follow_target = winner
	phantom_camera_2d.zoom = Vector2(2, 2)


func _init_camera():
	for player in players.get_children():
		phantom_camera_2d.append_follow_targets(player)
		
