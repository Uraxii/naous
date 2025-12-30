class_name NaousNet extends Node

## Peer ID of the server (will always be 1).
const SERVER_PEER_ID := 1

@onready var lg := Globals.logger
@onready var signals := Globals.signal_bus

var current_level: Node

## Peer ID of the local client.
## Alias for multiplayer.get_unique_id()
var my_peer_id: int:
    get: return multiplayer.get_unique_id()

## Alias for multiplayer.get_remote_sender_id().
## This should only be called inside RPC functions.
## Returns the peer ID of the peer that triggered the current RPC being run.
var sender_peer_id: int:
    get: return multiplayer.get_remote_sender_id()


## Callde by ClientNet, implemented on ClientNet
func fetch(fetch_func: Callable, ...args) -> Signal:
    push_error("Fetch not implemented on %s" % get_path())
    var promise_that_never_gets_fufilled := Promise.new()
    return promise_that_never_gets_fufilled.trigger


## Called by ServerNet, implemented on ClientNet.
@rpc("authority", "call_remote", "reliable")
func respond(promise_id: int, data: Dictionary) -> void:
    push_error("Return not implemented on %s" % get_path())


@rpc("any_peer", "call_remote", "reliable")
func set_current_actor(actor_iid: int) -> void:
    push_error("set_current_actor not implemented on %s" % get_path())



## Called by ClientNet, implemented on ServerNet
@rpc("any_peer", "call_remote", "reliable")
func create_new_player(promise_id: int) -> void:
    push_error("create_new_player not implemented on %s" % get_path())


## Called by ClientNet, implemented on ServerNet.
@rpc("any_peer", "call_remote", "reliable")
func fetch_my_actor(promise_id: int) -> void:
    push_error("fetch_my_actor not implemented on %s" % get_path())


## Called by ClientNet, implemented on ServerNet.
@rpc("any_peer", "call_remote", "reliable")
func fetch_all_actor_data(promise_id: int) -> void:
    push_error("fetch_all_player_data not implemented on %s" % get_path())


## Called by ClientNet, implemented on ServerNet.
@rpc("any_peer", "call_remote", "reliable")
func fetch_actor_data(promise_id: int, user_id: int) -> void:
    push_error("fetch_player_data not implemented on %s" % get_path())


@rpc("any_peer", "call_remote", "reliable")
func set_player_data(data: Dictionary) -> void:
    push_error("set_player_data not implemented on %s" % get_path())


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
