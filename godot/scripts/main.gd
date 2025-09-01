class_name Main extends Node

enum ServerMode {
    CLIENT,
    HEADLESS_SERVER
}

var server_mode: ServerMode = ServerMode.CLIENT
var shard_config: Dictionary = {}


func _ready() -> void:
    Globals.views.spawn(ConsoleView)
    var args := ArgParser.parse()
    
    print("Args=", args)
    
    # Check if running as headless server
    if _is_server_mode(args):
        server_mode = ServerMode.HEADLESS_SERVER
        _initialize_server(args)
    else:
        server_mode = ServerMode.CLIENT
        _initialize_client(args)


func _is_server_mode(args: Dictionary) -> bool:
    """Check if we should run as a headless server."""
    return args.has("headless") or args.has("server") or args.has("shard_id")


func _initialize_server(args: Dictionary) -> void:
    """Initialize as a headless server shard."""
    print("Initializing as headless server...")

    var instance_cfg := InstanceConfig.new()
    if args.has("level"):
        var level_name = args.get("level")
        instance_cfg.level = load(
            "res://scenes/world/zones/%s.tscn" % level_name)
    InstanceAPI.start_server(instance_cfg)


func _initialize_client(args: Dictionary) -> void:
    """Initialize as a normal client."""
    print("Initializing as client...")
    
    if args.has("auto_connect"):
        InstanceAPI.start_client()
        return
    
    Globals.views.spawn(MainView)
