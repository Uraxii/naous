class_name TestRpcPromise extends Node

@onready var signals := Globals.signal_bus
@onready var arguments := Globals.launch_args

@onready var server := Server.new()
@onready var client := Client.new()


func start_server() -> void:
    push_warning("I am the server.")
    var multiplayer_peer = ENetMultiplayerPeer.new()
    var error = multiplayer_peer.create_server(7000, 100)

    if error:
        push_error("Failed to start server!")
        return

    server.name = "Network"
    add_child.call_deferred(server, true)

    multiplayer.multiplayer_peer = multiplayer_peer


func start_client(address:="localhost", port:=7000) -> void:
    push_warning("I am the client.")

    var multiplayer_peer = ENetMultiplayerPeer.new()
    var error = multiplayer_peer.create_client(address, port)

    if error:
        push_error("Failed to start client!")
        return

    client.name = "Network"
    add_child(client, true)

    multiplayer.multiplayer_peer = multiplayer_peer


func run_test() -> void:
    # Waiting frames to give the server time to start.
    for i in range(0, 30):
        await get_tree().process_frame

    var new_player_data := ComponentData.new()
    client.set_player_data.rpc_id(Server.PEER_ID, new_player_data)

    var resp = await client.Fetch(
        client.fetch_player_data, client.peer_id)
    lg.debug(resp)

    resp = await client.Fetch(client.fetch_all_player_data)
    lg.debug(resp)


func _ready() -> void:
    Globals.views.spawn(ConsoleView)
    lg.debug("Args=", arguments)


    if arguments.has("server"):
        start_server()
    else:
        start_client()
        run_test()

