class_name MsgRouter extends Node

@onready var signals    := Globals.signal_bus
@onready var logger     := Globals.logger

var routes: Dictionary[BFT.ID, Signal] = {  }


static func generate_msg_routes(bus: SignalBus) -> Dictionary[BFT.ID, Signal]:
    return {
        BFT.ID.MSG_TEST: bus.test_msg,
        BFT.ID.MSG_CHAT: bus.chat_msg,
        BFT.ID.MSG_SPAWN_ACTOR: bus.spawn_actor,
        BFT.ID.MSG_DELETE_ACTOR: bus.delete_actor,
        BFT.ID.MSG_UPDATE_ACTOR: bus.update_actor,
    }


func client_send_to_server(msg: Msg) -> void:
    _server_recieve_msg.rpc_id(1, Serializer.to_dict(msg))


@rpc("any_peer", "call_remote")
func _server_recieve_msg(msg: Dictionary) -> void:
    if not multiplayer.is_server():
        return

    _route_msg(msg)


func send(msg: Msg) -> void:
    var serialized_msg := Serializer.to_dict(msg)
    _route_msg.rpc(serialized_msg)


@rpc("any_peer", "call_local")
func _route_msg(msg: Dictionary) -> void:
    if not validate_message(msg):
        return

    logger.debug("Received message:", msg)
    var new_msg: Msg = Serializer.from_dict(msg)

    if not routes.has(new_msg.get_id()):
        logger.warn("No route for message!\tMSG:", msg)
        return

    routes[msg.type].emit(new_msg)


func validate_message(msg: Dictionary) -> bool:
    if not msg.has("payload") and msg["payload"] is Dictionary:
        logger.warn("Invaid msg payload!\tMSG:", msg)
        return false

    if not msg.has("type") or not BFT.get_type(msg["type"]):
        logger.warn("Invalid msg type!\tMSG:", msg)
        return false

    return true


func send_test_message() -> void:
    var test_msg := MsgTest.new()
    send(test_msg)


func _on_test_message(msg: MsgTest) -> void:
    logger.debug("Got test message!")


#region Godot Callback Functions
func _ready() -> void:
    routes = generate_msg_routes(signals)
    signals.connected_to_server.connect(send_test_message)
    signals.test_msg.connect(_on_test_message)
#endregion
