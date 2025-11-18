class_name HTTPManager extends Node

@onready var signals := Globals.signal_bus
@onready var session := Globals.session

var available_requesters: Array[HTTPRequest] = []

var base_url := "http://localhost:8000"


func login(user: String, secret: String) -> Array:
	var url = base_url + "/api/login"
	var body = { "user_id": user, "secret": secret }
	var response = await send(url, HTTPClient.METHOD_POST, body)
	return response


func send(url: String, method: int, body := {} ) -> Signal:
	var headers = ["Content-Type: application/json" ]
	var json_body := ""

	if body:
		json_body = JSON.stringify(body)
		#print_debug("json body: %s" % json_body)

	var requester := _lease_requester()
	requester.request(url, headers, method, json_body)
	return requester.request_completed


func _lease_requester() -> HTTPRequest:
	var requester: HTTPRequest = available_requesters.pop_front()
	if not requester:
		requester = HTTPRequest.new()
		add_child(requester)

	requester.request_completed.connect(
		func(_result, _code, _headers, _body):
			var connections = requester.request_completed.get_connections()
			for conn in connections:
				requester.request_completed.disconnect(conn['callable'])
			available_requesters.append(requester))

	return requester


func check_heartbeat() -> void:
	var response_signal := send(base_url + "/version", HTTPClient.METHOD_GET)
	response_signal.connect(_on_heartbeat_response)


func _on_heartbeat_response(_result, code, _headers, _body) -> void:
	print_debug("Heartbeat: %d" % code)


func _ready() -> void:
	var requester = HTTPRequest.new()
	add_child(requester)
	available_requesters.append(requester)

	check_heartbeat()
