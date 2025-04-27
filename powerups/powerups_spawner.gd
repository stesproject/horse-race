extends Node2D

@export var spawn_chance : float = 0.3
@export var spawn_delay_range: Vector2 = Vector2(3, 6)

const SLOW_DOWN = preload("res://powerups/slow_down.tscn")
const SPEED_UP = preload("res://powerups/speed_up.tscn")
const SHIELD = preload("res://powerups/shield.tscn")
const FURY_ATTACK = preload("res://powerups/fury_attack.tscn")
const MAX_SPAWNED_POWERUPS = 5

@onready var timer: Timer = $Timer

var powerups: Array


func _ready() -> void:
	powerups = [SHIELD, FURY_ATTACK]
	await SignalBus.start_race
	_start_timer()


func _on_timer_timeout() -> void:
	if randf() < spawn_chance:
		_start_timer()
		return
	var spawned_powerups = get_tree().get_nodes_in_group("powerup").size()
	if spawned_powerups >= MAX_SPAWNED_POWERUPS:
		return
	if get_child_count() >= 2:
		return
	var powerup = powerups[randi() % powerups.size()].instantiate()
	add_child(powerup)
	_start_timer()


func _start_timer():
	timer.wait_time = randf_range(spawn_delay_range.x, spawn_delay_range.y)
	timer.start()
