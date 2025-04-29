extends Node

var horses_speed = 0.0

var peer = ENetMultiplayerPeer.new()
var online_game := false

const SERVER_PORT = 3030
const SERVER_HOST = "localhost"


func create_server() -> void:
	peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	online_game = true


func create_client() -> void:
	peer.create_client(SERVER_HOST, SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	online_game = true
