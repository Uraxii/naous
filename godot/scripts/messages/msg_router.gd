class_name MsgRouter extends Node

@onready var signals    := Globals.signal_bus
@onready var logger     := Globals.logger

var routes: Dictionary[Msg.Type, Signal] = {  }


static func generate_msg_routes(
    bus: SignalBus
) -> Dictionary[Msg.Type, Signal]:
    return {
        Msg.Type.TEST: bus.test_msg,
        Msg.Type.SPAWN_ENTITY: bus.spawn_entity_msg,
    }


func send(msg: Msg) -> void:
    _receive.rpc(Msg.serialize(msg))


@rpc("any_peer")
func _receive(serialized_msg: Dictionary) -> void:
    var msg = Msg.deserialize(serialized_msg)
    logger.debug("Received message:", msg.data)


func send_test_message() -> void:
    var test_msg := MsgTest.new()
    send(test_msg)


#region Godot Callback Functions
func _ready() -> void:
    routes = generate_msg_routes(signals)
    signals.connected_to_server.connect(send_test_message)
#endregion
