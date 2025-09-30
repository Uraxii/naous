class_name GlobalManager extends Node

@onready var signals: SignalBus = add(SignalBus)
@onready var websocket: WebSocketManager = add(WebSocketManager)
@onready var http: HTTPManager = add(HTTPManager)

var session := Session.new()


func add(type: GDScript) -> Node:
    var obj = type.new()
    add_child(obj)
    return obj
