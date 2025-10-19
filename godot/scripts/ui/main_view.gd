class_name MainView extends View

@export var username: LineEdit
@export var password: LineEdit
@export var join: Button


func _ready() -> void:
    join.pressed.connect(_on_join_pressed)


func _on_join_pressed() -> void:
    var response  = await http.login("Nicole", "Password")

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

