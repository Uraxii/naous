class_name Chat extends Control

@export var player_name: LineEdit
@export var chat_log: RichTextLabel
@export var text_input: TextEdit
@export var send_message_button: Button

@onready var signals := Globals.signals
@onready var session := Globals.session
@onready var http := Globals.http
@onready var ws := Globals.websocket


func log_chat(message: String) -> void:
    chat_log.text += "\n" + message


func _on_send_message_button_pressed() -> void:
    if not text_input.text:
        return

    var message = {
        "action": "ChatMessage",
        "peer_id": session.peer_id,
        "session_token": session.token,
        "payloads": {
            "sender": "Evil",
            "message": text_input.text,
            "evil": "mwuahahaha >:D",
        }
    }
    
    ws.send(message)
    text_input.text = ""


func _on_chat_message_received(packet) -> void:
    var payloads = packet.get("payloads")
    if not payloads:
        return
        
    var sender = payloads.get("sender", "")
    var message = payloads.get("message", "")
    if not sender or not message:
        push_warning("ChatPacket missing data!")
        return

    var chat_str = "%s: %s" % [sender, message]
    log_chat(chat_str)
    

func _on_server_message_received(packet) -> void:
    var payloads = packet.get("payloads")
    if not payloads:
        return
    
    var message = payloads.get("message")
    if not message:
        return

    log_chat(message)

    
func _on_connection_closed() -> void:
    chat_log.text = ""


func _ready() -> void:
    signals.chat_message_received.connect(_on_chat_message_received)
    signals.server_message_received.connect(_on_server_message_received)
    signals.connection_closed.connect(_on_connection_closed)
    send_message_button.pressed.connect(_on_send_message_button_pressed)    
