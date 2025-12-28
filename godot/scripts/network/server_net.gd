class_name ServerNet extends NaousNet

## Timer that triggers every server tick. Tick time is set by the config file.
@onready var tick_timer := Timer.new()
@onready var actors := Globals.actors
@onready var actor_db := Globals.actor_db
@onready var instance_db := Globals.instance_db

var db := DB.new()
var connected_peers: Array[int] = [  ]
var config: InstanceConfig = preload(
    "res://resources/default_instance_config.tres")

## Returns true is the max number of peers are connected.
var server_is_full: bool:
    get: return connected_peers.size() >= config.size


func fetch_peer_actor_id(peer_id: int) -> int:
    var actor_id = actors.players.get(peer_id, Actor.INVALID_ID)
    return actor_id


@rpc("any_peer", "call_remote", "reliable")
func fetch_my_actor(promise_id: int) -> void:
    lg.debug(actor_db.pool)
    var resp := MsgActorData.new()
    var actor_id = actors.players.get(sender_peer_id, Actor.INVALID_ID)

    if not actor_id:
        lg.debug("No actor assigned to peer %d!" % sender_peer_id)
        resp.err = BFT.Err.ERR_ACTOR_NOT_FOUND
        respond.rpc_id(sender_peer_id, promise_id, resp.serialize())
        return

    var data := actor_db.find(actor_id)
    resp.actor_data = data
    lg.debug(resp.actor_data.serialize())
    respond.rpc_id(sender_peer_id, promise_id, Serializer.to_dict(resp))


## Fetches all player data from the database.
@rpc("any_peer", "call_remote", "reliable")
func fetch_all_actor_data(promise_id: int) -> void:
    var all_players := actor_db.get_all()

    lg.debug(promise_id)

    var msg := MsgAllPlayerData.new()
    msg.promise_id = promise_id
    for player in all_players:
        msg.player_data.append(player.serialize())

    respond.rpc_id(
        sender_peer_id,
        promise_id,
        Serializer.to_dict(msg)
    )


## Fetches player data from the database.
@rpc("any_peer", "call_remote", "reliable")
func fetch_actor_data(promise_id: int, actor_id: int) -> void:
    var data := actor_db.find(actor_id)
    var resp := MsgActorData.new()
    resp.actor_data = data
    respond.rpc_id(sender_peer_id, promise_id, resp.serialize())


## Sets player data.
@rpc("any_peer", "call_remote", "reliable")
func set_player_data(data: Dictionary) -> void:
    var actor_id = fetch_peer_actor_id(sender_peer_id)
    if actor_id == Actor.INVALID_ID:
        return

    var actor: ComponentData = actor_db.find(actor_id)
    if not actor:
        return

    actor.deserialize(data)


## Loads a level scene.
@rpc("authority", "call_remote", "reliable")
func load_level(level_name: String) -> void:
    var level_path: String = "res://scenes/world/zones/%s.tscn" % level_name
    lg.debug("Loading %s" % level_path)
    print_debug(level_path)
    var level_scene: PackedScene = load(level_path)

    if level_scene:
        var level_node: Node = level_scene.instantiate()
        get_tree().root.add_child.call_deferred(level_node)


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
    new_player.peer_auth_id = peer_id
    actors.players[peer_id] = new_player.id


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
