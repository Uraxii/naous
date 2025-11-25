class_name Main extends Node

@onready var signals := Globals.signal_bus
@onready var arguments := Globals.launch_args


func _connect_to_instance(args: Dictionary) -> void:
    print("Connecting to instance server...")
    InstanceAPI.start_client("localhost", 9000)


func _initialize_server(args: Dictionary) -> void:
    print("Initializing as headless server...")

    var instance_cfg := InstanceConfig.new()
    InstanceAPI.start_server(instance_cfg)


func _ready() -> void:
    Globals.views.spawn(ConsoleView)

    print_debug("Initializing as client...")
    print_debug("Args=", arguments)

    if arguments.has("server"):
        _initialize_server(arguments)
    elif arguments.has("client"):
        _connect_to_instance(arguments)
    else:
        Globals.views.spawn(CharacterSelectView)
