class_name NaousNet extends Node

## Peer ID of the server (will always be 1).
const SERVER_PEER_ID := 1

@onready var lg := Globals.logger
@onready var signals := Globals.signal_bus

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
    push_error("Fetch not implemented on %s" % name)
    var promise_that_never_gets_fufilled := Promise.new()
    return promise_that_never_gets_fufilled.trigger


## Called by ServerNet, implemented on ClientNet.
@rpc("authority", "call_remote", "reliable")
func respond(promise_id: int, data: Dictionary) -> void:
    push_error("Return not implemented on %s" % name)


## Called by ClientNet, implemented on ServerNet.
@rpc("any_peer", "call_remote", "reliable")
func fetch_my_actor(promise_id: int) -> void:
    push_error("fetch_my_actor not implemented on %s" % name)


## Called by ClientNet, implemented on ServerNet.
@rpc("any_peer", "call_remote", "reliable")
func fetch_all_player_data(promise_id: int) -> void:
    push_error("fetch_all_player_data not implemented on %s" % name)


## Called by ClientNet, implemented on ServerNet.
@rpc("any_peer", "call_remote", "reliable")
func fetch_player_data(promise_id: int, user_id: int) -> void:
    push_error("fetch_player_data not implemented on %s" % name)


@rpc("any_peer", "call_remote", "reliable")
func set_player_data(user_id: int, data: Dictionary) -> void:
    push_error("set_player_data not implemented on %s" % name)



@rpc("authority", "call_remote", "reliable")
func load_level(level_name: String) -> void:
    push_error("laod_level not implemented on %s" % name)
