class_name UserInterface extends Control

@export var connect_button: Button
@export var disconnect_button: Button
@export var player_name: LineEdit
@export var chat_window: Chat
@export var input_text: TextEdit
@export var send_message_button: Button

@onready var signals := Globals.signals
@onready var session := Globals.session
@onready var http := Globals.http
@onready var ws := Globals.websocket

var base_http_url := "http://localhost:8000"


func _on_connect_button_pressed() -> void:
    var url = base_http_url + "/api/login"
    var body = {"user_id": player_name.text, "secret": "nothing"}
    var response = await http.send(url, HTTPClient.METHOD_POST, body)
    
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
  

func _on_disconnect_button_pressed() -> void:
    var url = base_http_url + "/api/logout"
    var body = {"peer_id": session.peer_id, "session_token": session.token}
    var response = await http.send(url, HTTPClient.METHOD_POST, body)
    
    var code: int = response[1]
    if code == 200:
        var resp_body = response[3]
        var data = JSON.parse_string(resp_body.get_string_from_utf8())
        print_debug(data['message'])
        chat_window.log_chat(data['message'])
    
    signals.logged_out.emit()
    
    if ws.socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
        ws.close()

func _on_deny_recieved(packet) -> void:
    var message = packet.payloads.get("message")
    var reason = packet.payloads.get("reason")
    chat_window.log_chat("Denied! Messge: %s, Reason: %s" % [message, reason])


func _on_claim_token_recieved(packet) -> void:
    session.peer_id = packet.payloads.get("peer_id")
    disconnect_button.show()
    player_name.hide()
    connect_button.hide()
    input_text.show()
    send_message_button.show()


func _on_connected_to_server() -> void:
    var claim_token_message = {
        "action": "ClaimTokenReq",
        "payloads": {
            "peer_id": session.peer_id,
            "session_token_to_claim": session.token,
        }
    }
    
    ws.send(claim_token_message)


func _on_connection_closed() -> void:
    connect_button.show()
    player_name.show()
    disconnect_button.hide()
    input_text.hide()
    send_message_button.hide()


func _ready() -> void:
    signals.connected_to_server.connect(_on_connected_to_server)
    signals.connection_closed.connect(_on_connection_closed)
    signals.deny_received.connect(_on_deny_recieved)
    signals.claim_token_received.connect(_on_claim_token_recieved)
    connect_button.pressed.connect(_on_connect_button_pressed)
    disconnect_button.pressed.connect(_on_disconnect_button_pressed)

    if not ws.is_socket_connected:
        _on_connection_closed()
