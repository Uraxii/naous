class_name Client extends Node

@onready var lg := Globals.logger

var promises := PromiseManager.new()

var peer_id: int:
    get: return multiplayer.get_unique_id()


func Fetch(fetch_func: Callable, ...args) -> Signal:
    var promise = promises.create()
    var arguments: Array = [Server.PEER_ID, promise.id]
    arguments.append_array(args)
    #lg.debug(arguments)
    fetch_func.rpc_id.callv(arguments)
    return promise.trigger


## Fufills promise with [param promise_id] id.
## Called by the server, implemented on the client.
@rpc("authority", "call_remote", "reliable")
func Return(promise_id: int, data: Dictionary) -> void:
    promises.fulfill(promise_id, data)


## Called by the client, implemented on the server.
@rpc("any_peer", "call_remote", "reliable")
func fetch_all_player_data(promise_id: int) -> void:
    pass


## Called by the client, implemented on the server.
@rpc("any_peer", "call_remote", "reliable")
func fetch_player_data(promise_id: int, user_id: int):
    pass


## Called by the client, implemented on the server.
@rpc("any_peer", "call_remote", "reliable")
func set_player_data(data: Dictionary) -> void:
    pass
