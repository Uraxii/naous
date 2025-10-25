class_name Main extends Node

@onready var signals := Globals.signal_bus
@onready var http := Globals.http
@onready var ws := Globals.websocket
@onready var session := Globals.session
@onready var arguments := Globals.launch_args


func _auto_connect(args: Dictionary) -> void:
    print_debug("Autoconnecting...")

    var response = await http.login(args['user'], args['secret'])

    var code: int = response[1]
    if code != 200:
        push_error("Login failed!")
        return

    signals.logged_in.emit()

    var resp_body = response[3]
    var data = JSON.parse_string(resp_body.get_string_from_utf8())
    session.token = data['session_token']

    var endpoint = "ws://%s:%d/%s" % [
    ws.SERVER_ADDRESS, ws.SERVER_PORT, ws.WEBSOCKET_ENDPOINT]

    var error = ws.connect_to_url(endpoint)
    if error:
        push_error("Unable to connec to %s" % endpoint)


func _connect_to_instance(args: Dictionary) -> void:
    print("Connecting to instance server...")
    InstanceAPI.start_client("localhost", 9000)


func _initialize_server(args: Dictionary) -> void:
    print("Initializing as headless server...")

    var instance_cfg := InstanceConfig.new()
    InstanceAPI.start_server(instance_cfg)


func _ready() -> void:
    print_debug("Initializing as client...")
    print_debug("Args=", arguments)

    if arguments.has("server"):
        _initialize_server(arguments)
    elif arguments.has("client"):
        _auto_connect(arguments)
    elif arguments.has("connect-to-instance"):
        _connect_to_instance(arguments)
    else:
        Globals.views.spawn(MainView)
