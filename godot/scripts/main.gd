class_name Main extends Node

@onready var signals := Globals.signal_bus
@onready var arguments := Globals.launch_args


func _initialize_client(args: Dictionary) -> void:
    print_debug("Initializing as client...")
    Globals.views.spawn(CharacterSelectView)
    


func _initialize_server(args: Dictionary) -> void:
    print("Initializing as server...")
    InstanceAPI.start_server()


func _ready() -> void:
    Globals.views.spawn(ConsoleView)

    print_debug("user://: ", OS.get_user_data_dir())
    print_debug("Args=", arguments)

    if arguments.has("server"):
        _initialize_server(arguments)
    else:
        _initialize_client(arguments)
