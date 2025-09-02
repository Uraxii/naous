class_name InstanceApi extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

#region Instance Variables
var is_server: bool:
    get: return multiplayer.is_server()

var my_peer_id: int:
    get: return multiplayer.get_unique_id()

var server_is_full: bool:
    get: return connections.size() >= config.size

var signals: SignalBus:
    get: return Globals.signal_bus
    
var entities: EntityManager:
    get: return Globals.entities


var config: InstanceConfig = preload(
    "res://resources/default_instance_config.tres")

var connections: Dictionary[int, PlayerData] = {}

# Don't use this outside of RPC functions!
var _sender_id: int:
    get: return multiplayer.get_remote_sender_id()
#endregion

#region Start Multiplayer Functions
func start_client(address=config.host, port=config.port) -> void:
    signals.log_new_debug.emit("Connecting to %s:%d" %[address, port])
    var multiplayer_peer = ENetMultiplayerPeer.new()
    var error = multiplayer_peer.create_client(address, port)

    if error:
        signals.log_new_error.emit(error)
        return

    multiplayer.multiplayer_peer = multiplayer_peer


func start_server(cfg: InstanceConfig) -> void:
    signals.log_new_debug.emit("Starting server.")
    config = cfg
    var multiplayer_peer = ENetMultiplayerPeer.new()
    var error = multiplayer_peer.create_server(cfg.port, cfg.size)

    if error:
        signals.log_new_error.emit(error)
        return

    multiplayer.multiplayer_peer = multiplayer_peer
    print_debug(config.level.resource_name)
    load_level(config.level.instantiate().name)
#endregion


@rpc("authority", "call_remote", "reliable", 1)
func load_level(level_name: String) -> void:
    var level_path: String = "res://scenes/world/zones/%s.tscn" % level_name
    signals.log_new_debug.emit("Loading %s" % level_path)
    print_debug(level_path)
    var level_scene: PackedScene = load(level_path)

    if level_scene:
        var level_node: Node = level_scene.instantiate()
        add_child(level_node)


func _spawn_player(authority: int, user_name: String, character_name: String) -> void:
    if not is_server:
        return

    print_debug("Sender %d" % authority)

    var player_data = PlayerData.new(user_name, authority)
    player_data.set_character_data(character_name)

    if connections.has(authority):
        return

    var spawn_data = {
        "authority": authority,
        "id": player_data.id
    }
    
    var entity: Entity = entities.spawn(spawn_data)
    player_data.entity = entity
    connections[authority] = player_data

    signals.log_new_debug.emit("%s spawned." % player_data.id)
    player_connected.emit(authority, player_data)


@rpc("any_peer", "call_remote", "reliable")
func _request_spawn(user_name: String, character_name: String) -> void:
    _spawn_player(_sender_id, user_name, character_name)


func _set_authority(entity: Entity, peer_id: int) -> void:
    entity.authority_id = peer_id


#region Signal Handlers
func _on_player_connected(peer_id: int) -> void:
    signals.log_new_debug.emit("Peer %d connected." % peer_id)

    if is_server:
        load_level.rpc_id(peer_id, config.level.instantiate().name)


func _on_player_disconnected(peer_id: int) -> void:
    if connections.has(peer_id):
        var player_id = connections[peer_id].id
        signals.log_new_debug.emit("%s disconnected." % player_id)

    player_disconnected.emit(peer_id)


func _on_connected_ok() -> void:
    var char_data: CharacterData = load(
        "res://resources/dummy_character_data.tres")
    # Request server to spawn this player
    _request_spawn.rpc_id(1, "Nicole", char_data.name)


func _on_connected_fail() -> void:
    signals.log_new_error.emit("Failed to connect.")
    multiplayer.multiplayer_peer = null


func _on_server_disconnected() -> void:
    signals.log_new_warning.emit("Disconnected from server.")
    multiplayer.multiplayer_peer = null
    connections.clear()
    server_disconnected.emit()
#endregion

#region Godot Callback functions
func _ready() -> void:
    multiplayer.peer_connected.connect(_on_player_connected)
    multiplayer.peer_disconnected.connect(_on_player_disconnected)
    multiplayer.connected_to_server.connect(_on_connected_ok)
    multiplayer.connection_failed.connect(_on_connected_fail)
    multiplayer.server_disconnected.connect(_on_server_disconnected)
#endregion
