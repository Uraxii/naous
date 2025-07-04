class_name GlobalManager extends Node

@onready var signal_bus: SignalBus = _new_global(SignalBus)
@onready var message_router: MessageRouter = _new_global(MessageRouter)
@onready var controllers: ControllerManager = _new_global(ControllerManager)
@onready var views: ViewManager = _new_global(ViewManager)
@onready var local_player: LocalPlayer = _new_global(LocalPlayer)
    

func _new_global(type: GDScript) -> Node:
    var instance = type.new()
    add_child(instance)
    return instance
