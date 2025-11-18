class_name MockApiClientImpl extends ApiClientImpl

@onready var logger := Globals.logger
@onready var signals := Globals.signal_bus

var _character_data:Dictionary[int, Dictionary]
var _username:String = ""
var _player_id:int

func _ready() -> void:
	_player_id = randi_range(1,10000)
	_username = "player%d" % _player_id

	_character_data = {
		1: {
			"name": "Foobar",
			"id": 1,
			"user_id": _player_id,
			"stats": {
				"vigor": 1
			},
			"equipment": {},
			"inventory": {},
			"created_at": "2025-07-16T03:58:12.792101",
			"last_played": "2025-07-16T03:58:12.792106"
		}
	}
#region Authentication
func loggerin(username: String, password: String) -> void:
	_username = username
	parent.access_token = _create_access_token()

	logger.success("Login successful! Player ID: %d" % _player_id)
	signals.loggerin_success.emit()

func register(username: String, password: String) -> void:
	_username = username
	var data: Dictionary = { username = _username}
	parent.access_token = _create_access_token()

	logger.success("Registration successful!")
	signals.register_success.emit(data)

func loggerout() -> void:
	parent.access_token = ""
	logger.info("Logged out successfully")
	signals.loggerout_success.emit()

func _create_access_token() -> String:
	var random_string:PackedStringArray = []
	for i in 20:
		var byte:int = randi_range(0, 35)
		# "0"-"9" or "A" - "Z"
		random_string.push_back(char( 48 + byte if byte <= 9 else 65 + byte - 10))

	return "".join(random_string)

func refresh_token() -> void:
	logger.info("Token refreshed successfully")
	parent.access_token = _create_access_token()
	signals.token_refresh_success.emit()

func get_me() -> void:
	# TODO: User peer id as player id
	signals.user_info_received.emit({username = "player%d" % _player_id})
#endregion


#region Character Management

func get_all_characters(skip: int = 0, limit: int = 10) -> void:
	logger.info("Fetched %d characters" % _character_data.size())
	var characters_array = _character_data.values()
	signals.characters_received.emit(characters_array, _character_data.size())

func get_character(character_id: int) -> void:
	if character_id in _character_data:
		var character_data = _character_data[character_id]
		logger.info("Fetched character: %s" % character_data.name)
		signals.character_received.emit(character_data)
	else:
		signals.character_not_found.emit()
		logger.error("Character not found!")

func create_character(name: String) -> void:
	var id:int = _character_data.size() * 100 + 1

	var character_data:Dictionary = {
		"name": name,
		"id": id,
		"user_id": _player_id,
		"stats": {
			"vigor": 1
		},
		"equipment": {},
		"inventory": {},
		"created_at": "2025-07-16T03:58:12.792101",
		"last_played": "2025-07-16T03:58:12.792106"
	}
	_invoke_replicated("_create_character", id, character_data)

func update_character(character_id: int, updates: Dictionary) -> void:
	_invoke_replicated("_update_character", character_id, updates)

func delete_character(character_id: int) -> void:
	_invoke_replicated("_delete_character", character_id)
#endregion

#region Utility
func status() -> void:
	signals.api_status_passed.emit()

func _invoke_replicated(method:String, ...args: Array) -> void:
	# First invoke locally - doing this simplifies loggeric since then no ambiguity about local vs remote execution
	Callable(self, method).callv(args)

	if not multiplayer.has_multiplayer_peer():
		push_warning("No multiplayer peer - Invoked method=%s with args=%s" % [method, ",".join(args)])
		return
	if multiplayer.is_server():
		# Invoke as broadcast
		_rpcv(method, args)
	else:
		# Call on server - will rebroadcast to other clients
		_rpcv_id(1, method, args)

func _check_invoke_broadcast(method:String, ...args: Array) -> void:
	if not multiplayer.has_multiplayer_peer() or not multiplayer.is_server():
		return
	# Invoke on all but the originally sending peer
	var invoker:Callable = func()->void:
		for peer in multiplayer.get_peers():
			if peer != multiplayer.get_remote_sender_id():
				_rpcv_id(peer, method, args)

	invoker.call_deferred()
#endregion

#region RPCs
@rpc("any_peer", "call_remote", "reliable")
func _update_character(character_id: int, updates: Dictionary) -> void:
	if character_id in _character_data:
		_character_data[character_id] = updates
		logger.success("Character updated: %s" % updates.name)
		signals.character_updated.emit(updates)
	else:
		signals.character_not_found.emit()
		logger.error("Character not found!")

	_check_invoke_broadcast("_update_character", character_id, updates)

@rpc("any_peer", "call_remote", "reliable")
func _delete_character(character_id: int) -> void:
	var deleted:bool = _character_data.erase(character_id)

	if deleted:
		logger.success("Character deleted successfully")
		signals.character_deleted.emit()
	else:
		signals.character_not_found.emit()
		logger.error("Character not found!")

	_check_invoke_broadcast("_delete_character", character_id)

@rpc("any_peer", "call_remote", "reliable")
func _create_character(id: int, character_data: Dictionary) -> void:
	_character_data[id] = character_data

	logger.success("Character created: %s (ID: %d)" % [character_data.name, character_data.id])
	signals.character_created.emit(character_data)

	_check_invoke_broadcast("_create_character", id, character_data)

func _rpcv(method:String, args: Array) -> void:
	# Godot doesn't have a built in var args rpcv function
    match args.size():
        0: rpc(method)
        1: rpc(method, args[0])
        2: rpc(method, args[0], args[1])
        3: rpc(method, args[0], args[1], args[2])
        4: rpc(method, args[0], args[1], args[2], args[3])
        5: rpc(method, args[0], args[1], args[2], args[3], args[4])
        _: assert("Argument expansion not implemented for size=%d" % args.size())
        
func _rpcv_id(peer_id: int, method:String, args: Array) -> void:
	# Godot doesn't have a built in var args rpcv function
	match args.size():
		0: rpc_id(peer_id, method)
		1: rpc_id(peer_id, method, args[0])
		2: rpc_id(peer_id, method, args[0], args[1])
		3: rpc_id(peer_id, method, args[0], args[1], args[2])
		4: rpc_id(peer_id, method, args[0], args[1], args[2], args[3])
		5: rpc_id(peer_id, method, args[0], args[1], args[2], args[3], args[4])
		_: assert("Argument expansion not implemented for size=%d" % args.size())
#endregion
