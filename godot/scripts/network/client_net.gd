class_name ClientNet extends NaousNet

## Used to manage promises when performing fetch requests.
var promises := PromiseManager.new()
var local_player := ComponentData.new()


## Fufills promise with [param promise_id] id.
## Called by ServerNet, implemented on ClientNet.
@rpc("authority", "call_remote", "reliable")
func respond(promise_id: int, data: Dictionary) -> void:
    promises.fulfill(promise_id, data)


## Calls a fetch function on the server.
## Returns signal that is emited upon response from the server.
## Called by ClientNet, implemented on ClientNet
func fetch(fetch_func: Callable, ...args) -> Signal:
    var promise = promises.create()
    var arguments: Array = [SERVER_PEER_ID, promise.id]
    arguments.append_array(args)
    lg.debug(fetch_func, arguments)
    fetch_func.rpc_id.callv(arguments)
    return promise.trigger


## Connect client to a server.
func connect_to_server(address:="localhost", port:=9000) -> void:
    lg.debug("Connecting to %s:%d" %[address, port])
    var multiplayer_peer = ENetMultiplayerPeer.new()
    var error = multiplayer_peer.create_client(address, port)

    if error:
        signals.log_new_error.emit(error)
        return

    multiplayer.multiplayer_peer = multiplayer_peer


#region Signal Handlers
## Called when client successfully connects to a server.
func _on_connected_ok() -> void:
    signals.connected_to_server.emit()
    set_player_data.rpc_id(SERVER_PEER_ID, 1, local_player.serialize())
    var actor = await fetch(fetch_my_actor)
    lg.debug("my actor: ", actor)



## Called when client fails to connect to a server.
func _on_connected_fail() -> void:
    signals.log_new_error.emit("Failed to connect.")
    multiplayer.multiplayer_peer = null


## Called when the client is diconnected from a server.
func _on_server_disconnected() -> void:
    signals.log_new_warning.emit("Disconnected from server.")
    multiplayer.multiplayer_peer = null
    signals.server_disconnected.emit()


## Connects signals for this node. Called in _ready.
func connect_signals() -> void:
    multiplayer.connected_to_server.connect(_on_connected_ok)
    multiplayer.connection_failed.connect(_on_connected_fail)
    multiplayer.server_disconnected.connect(_on_server_disconnected)
#endregion

#region Godot Callback functions
func _ready() -> void:
    connect_signals()
#endregion

