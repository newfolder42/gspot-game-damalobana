extends Node

## NetworkManager — Autoload singleton for the hide-and-seek multiplayer game.
##
## Behaviour:
##   • Dedicated server build  → starts a WebSocket server on SERVER_PORT.
##   • Client / WebGL build    → exposes connect_to_server() so the UI can
##                               initiate a connection to a given WebSocket URL.

const SERVER_PORT: int = 8080
const MAX_CLIENTS: int = 32

var _peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()

# Emitted when a new client connects (server-side).
signal client_connected(peer_id: int)

# Emitted when a client disconnects (server-side).
signal client_disconnected(peer_id: int)

# Emitted on the client when the connection to the server is established.
signal connected_to_server()

# Emitted on the client when the connection to the server is lost.
signal disconnected_from_server()


func _ready() -> void:
	# Wire up multiplayer signals once here to avoid duplicate connections.
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_disconnected_from_server)

	if OS.has_feature("dedicated_server"):
		_start_server()
	# On the client side, the UI calls connect_to_server() explicitly.


# ── Server ────────────────────────────────────────────────────────────────────

func _start_server() -> void:
	var err: Error = _peer.create_server(SERVER_PORT, MAX_CLIENTS)
	if err != OK:
		push_error("NetworkManager: failed to create WebSocket server on port %d (error %d)" % [SERVER_PORT, err])
		return

	multiplayer.multiplayer_peer = _peer

	print("NetworkManager: WebSocket server listening on port %d" % SERVER_PORT)


func _on_peer_connected(peer_id: int) -> void:
	print("NetworkManager: client connected — peer_id=%d" % peer_id)
	client_connected.emit(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	print("NetworkManager: client disconnected — peer_id=%d" % peer_id)
	client_disconnected.emit(peer_id)


# ── Client ────────────────────────────────────────────────────────────────────

## Connect to a WebSocket server at *url* (e.g. "ws://example.com:8080").
## Call this from the main-menu or lobby UI after the player taps "Play".
func connect_to_server(url: String) -> void:
	var err: Error = _peer.create_client(url)
	if err != OK:
		push_error("NetworkManager: failed to connect to '%s' (error %d)" % [url, err])
		return

	multiplayer.multiplayer_peer = _peer

	print("NetworkManager: connecting to server at '%s' …" % url)


func _on_connected_to_server() -> void:
	print("NetworkManager: connected to server (my peer_id=%d)" % multiplayer.get_unique_id())
	connected_to_server.emit()


func _on_disconnected_from_server() -> void:
	print("NetworkManager: disconnected from server")
	disconnected_from_server.emit()
	_peer.close()
	_peer = WebSocketMultiplayerPeer.new()
	multiplayer.multiplayer_peer = null
