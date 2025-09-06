# godot/scripts/shard_connection.gd
class_name ShardConnection extends Node
## Handles connection to game shard servers

signal connected_to_shard
signal disconnected_from_shard  
signal connection_failed

var multiplayer_peer: ENetMultiplayerPeer
var character_data: Dictionary = {}
var connected: bool = false

@onready var signals := Globals.signal_bus
@onready var logger := Globals.logger


func connect_to_shard(host: String, port: int, character: Dictionary) -> void:
    """Connect to a game shard."""
    character_data = character
    
    logger.info("Connecting to shard: %s:%d" % [host, port])
    
    # Create multiplayer peer for client connection
    multiplayer_peer = ENetMultiplayerPeer.new()
    var error = multiplayer_peer.create_client(host, port)
    
    if error != OK:
        logger.error("Failed to create client connection: %s" % error)
        connection_failed.emit()
        return
    
    # Set up multiplayer
    multiplayer.multiplayer_peer = multiplayer_peer
    
    # Connect multiplayer signals
    multiplayer.connected_to_server.connect(_on_connected_to_server)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_server_disconnected)
    
    logger.info("Attempting connection...")


func disconnect_from_shard() -> void:
    """Disconnect from the current shard."""
    if multiplayer_peer:
        multiplayer_peer.close()
        multiplayer_peer = null
    
    connected = false
    
    # Disconnect signals to avoid issues
    if multiplayer.connected_to_server.is_connected(_on_connected_to_server):
        multiplayer.connected_to_server.disconnect(_on_connected_to_server)
    if multiplayer.connection_failed.is_connected(_on_connection_failed):
        multiplayer.connection_failed.disconnect(_on_connection_failed)
    if multiplayer.server_disconnected.is_connected(_on_server_disconnected):
        multiplayer.server_disconnected.disconnect(_on_server_disconnected)


func is_connected_to_shard() -> bool:
    """Check if currently connected to a shard."""
    return connected and multiplayer_peer != null and multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED


func send_chat_message(message: String) -> void:
    """Send a chat message to the shard."""
    if not is_connected_to_shard():
        logger.error("Not connected to shard")
        return
    
    var username = character_data.get("name", "Unknown")
    logger.info("Sending chat: %s" % message)
    
    # Call RPC on server
    receive_chat_message.rpc(message, username)


func send_player_position(position: Vector3, rotation: Vector3) -> void:
    """Send player position update to shard."""
    if not is_connected_to_shard():
        return
    
    # Call RPC on server  
    receive_player_position.rpc(position, rotation)


# Multiplayer event handlers

func _on_connected_to_server() -> void:
    """Called when successfully connected to shard server."""
    connected = true
    logger.success("Connected to shard server!")
    
    # Send authentication to server
    var username = character_data.get("name", "Player")
    var token = API.access_token  # Use the auth token from loggerin
    
    authenticate_player.rpc(username, token)
    
    connected_to_shard.emit()


func _on_connection_failed() -> void:
    """Called when connection to shard fails."""
    connected = false
    logger.error("Failed to connect to shard server")
    connection_failed.emit()


func _on_server_disconnected() -> void:
    """Called when disconnected from shard server."""
    connected = false
    logger.warn("Disconnected from shard server")
    disconnected_from_shard.emit()


# RPCs for communication with server

@rpc("any_peer", "call_remote", "reliable")
func receive_chat_message(message: String, username: String) -> void:
    """Send chat message to server (called by client)."""
    # This RPC is called ON the server, implemented in ServerManager
    pass


@rpc("any_peer", "call_remote", "unreliable")  
func receive_player_position(position: Vector3, rotation: Vector3) -> void:
    """Send position update to server (called by client)."""
    # This RPC is called ON the server, implemented in ServerManager
    pass


@rpc("any_peer", "call_remote", "reliable")
func authenticate_player(username: String, token: String) -> void:
    """Send authentication to server (called by client)."""
    # This RPC is called ON the server, implemented in ServerManager
    pass


# RPCs from server (called by server on client)

@rpc("authority", "call_remote", "reliable")
func receive_welcome_message(data: Dictionary) -> void:
    """Receive welcome message from server."""
    logger.info("Server welcome: %s" % data.get("message", ""))
    var player_count = data.get("player_count", 0)
    var max_players = data.get("max_players", 0)
    
    signals.logger_new_success.emit(
        "Joined hub! Players online: %d/%d" % [player_count, max_players]
    )


@rpc("authority", "call_remote", "reliable")
func receive_chat_from_server(sender_name: String, message: String, sender_id: int) -> void:
    """Receive chat message from server."""
    # Emit to the chat system
    signals.chat.emit(sender_name, message)


@rpc("authority", "call_remote", "reliable")
func receive_server_message(message: String) -> void:
    """Receive server announcement."""
    signals.logger_new_announcment.emit(message)


@rpc("authority", "call_remote", "reliable")
func receive_auth_confirmation(success: bool, username: String) -> void:
    """Receive authentication confirmation from server."""
    if success:
        logger.success("Authenticated in hub as: %s" % username)
        signals.logger_new_success.emit("Authenticated as: %s" % username)
    else:
        logger.error("Hub authentication failed")
        signals.logger_new_error.emit("Authentication failed")


@rpc("authority", "call_remote", "reliable") 
func receive_player_movement(player_id: int, position: Vector3, rotation: Vector3) -> void:
    """Receive other player's movement update."""
    # For MVP, just logger it. In full implementation, update player positions in world
    logger.info("Player %d moved to: %s" % [player_id, position])


@rpc("authority", "call_remote", "reliable")
func server_shutdown_notification(message: String) -> void:
    """Receive server shutdown notification."""
    logger.warn("Server shutting down: %s" % message)
    signals.logger_new_error.emit("Server shutting down: %s" % message)
