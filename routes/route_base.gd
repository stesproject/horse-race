extends Node2D

@export var player_scene: PackedScene

@onready var game_manager: GameManager = $GameManager

var peer = ENetMultiplayerPeer.new()

const PORT = 3030


func _on_host_button_pressed() -> void:
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	

func _add_player(id = 1):
	game_manager.player_id = id


func _on_join_button_pressed() -> void:
	peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = peer
