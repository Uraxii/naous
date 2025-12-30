class_name ServerNet extends NaousNet

## Timer that triggers every server tick. Tick time is set by the config file.
@onready var tick_timer := Timer.new()
@onready var actor_db := Globals.actor_db

var connected_peers: Array[int] = [  ]
var config: InstanceConfig = preload(
    "res://resources/default_instance_config.tres")

## Returns true is the max number of peers are connected.
var server_is_full: bool:
    get: return connected_peers.size() >= config.size


@rpc("any_peer", "call_remote", "reliable")
func set_player_data(data: Dictionary) -> void:
    if not actor_db.players.get(sender_peer_id):
        return

    var player_id: int = actor_db.players.get(sender_peer_id)
    var player: Entity = actor_db.find(player_id)


func start_server(cfg: InstanceConfig = config) -> void:
    lg.debug("Starting server.")
    push_warning("I am the server.")

    config = cfg

    tick_timer.wait_time = config.tick_interal
    tick_timer.autostart = true
    add_child.call_deferred(tick_timer)

    var multiplayer_peer = ENetMultiplayerPeer.new()
    var error = multiplayer_peer.create_server(cfg.port, cfg.size)

    if error:
        signals.log_new_error.emit(error)
        return

    multiplayer.multiplayer_peer = multiplayer_peer
    print_debug(config.level.resource_name)
    load_level(config.level.instantiate().name)


#region Signal Handlers
func _on_tick_timer_timeout() -> void:
    signals.network_tick.emit()


func _on_player_connected(peer_id: int) -> void:
    lg.debug("Peer %d connected." % peer_id)
    var new_player := actor_db.create()
    actor_db.assign_peer(new_player.id, peer_id)
    set_current_actor.rpc_id(peer_id, new_player.id)
    load_level.rpc_id(peer_id, "lake-natalie")
    actor_db.create_actor.rpc(new_player.components.serialize())


func _on_player_disconnected(peer_id: int) -> void:
    lg.debug("%s disconnected." % peer_id)

    if connected_peers.has(peer_id):
        connected_peers.erase(peer_id)

    signals.player_disconnected.emit(peer_id)


func connect_signals() -> void:
    tick_timer.timeout.connect(_on_tick_timer_timeout)
    multiplayer.peer_connected.connect(_on_player_connected)
    multiplayer.peer_disconnected.connect(_on_player_disconnected)
#endregion


#region Godot Callback functions
func _ready() -> void:
    connect_signals()
#endregion
