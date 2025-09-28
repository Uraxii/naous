class_name Main extends Node

@onready var signals := Globals.signal_bus
@onready var http := Globals.http
@onready var ws := Globals.websocket
@onready var session := Globals.session


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


func _ready() -> void:
    print_debug("Initializing as client...")

    Globals.views.spawn(ConsoleView)
    var args := ArgParser.parse()

    print_debug("Args=", args)

    if args.has("autoconnect"):
        _auto_connect(args)
        return

    Globals.views.spawn(MainView)
