class_name WebSocketManager extends Node

const SERVER_PORT := 8000
const SERVER_ADDRESS := "localhost"
const WEBSOCKET_ENDPOINT := "api/ws"

@onready var session = Globals.session
@onready var signals := Globals.signal_bus

var is_socket_connected: bool:
	get: return socket.get_ready_state() != socket.STATE_CLOSED

var socket: WebSocketPeer:
	get: return session.ws


func poll() -> void:
	if socket.get_ready_state() != socket.STATE_CLOSED:
		socket.poll()
		
	var state = socket.get_ready_state()
	
	if session.last_state != state:
		session.last_state = state
		
		if state == socket.STATE_OPEN:
			signals.connected_to_server.emit()
		elif state == socket.STATE_CLOSED:
			signals.connection_closed.emit()
	
	while socket.get_ready_state() == socket.STATE_OPEN and socket.get_available_packet_count():
		var packet_str = get_message()
		if not packet_str:
			continue
		
		var packet = JSON.parse_string(packet_str)
		print_debug(packet)
		
		match packet.get("action", "Malformed"):
			"ClaimTokenResp":
				signals.claim_token_received.emit(packet)
			"Deny":
				signals.deny_received.emit(packet)
			"ChatMessage":
				signals.chat_message_received.emit(packet)
			"ServerMessage":
				signals.server_message_received.emit(packet)
			_:
				push_warning("Unknown packet type received!")


func get_message() -> Variant:
	if not socket.get_available_packet_count():
		return null
	
	var packet = socket.get_packet()
	if socket.was_string_packet():
		return packet.get_string_from_utf8()
		
	push_warning("Not a string packet!")
	return
	# TODO: Verify security on this function. I think it may be dangerous.
	##return bytes_to_var(packet)


func send(message: Dictionary) -> int:
	var json = JSON.stringify(message)
	print_debug("Sending: %s" % json)
	return socket.send_text(json)
	
	# TODO: Verify security on this function. I think it may be dangerous.
	##return socket.send(var_to_bytes(message))
	
	
func connect_to_url(url) -> int:
	if session.last_state != socket.STATE_CLOSED:
		close()

	var error = socket.connect_to_url(url)
	if error:
		return error

	session.last_state = socket.get_ready_state()
	return OK
	

func close(code := 1000, reason := "") -> void:
	socket.close(code, reason)
 

func _process(_delta: float) -> void:
		poll()
