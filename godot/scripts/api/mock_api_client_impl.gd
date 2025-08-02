class_name MockApiClientImpl extends ApiClientImpl

@onready var log := Globals.log
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
func login(username: String, password: String) -> void:
	_username = username
	parent.access_token = _create_access_token()

	log.success("Login successful! Player ID: %d" % _player_id)
	signals.login_success.emit()

func register(username: String, password: String) -> void:
	_username = username
	var data: Dictionary = { username = _username}
	parent.access_token = _create_access_token()

	log.success("Registration successful!")
	signals.register_success.emit(data)

func logout() -> void:
	parent.access_token = ""
	log.info("Logged out successfully")
	signals.logout_success.emit()

func _create_access_token() -> String:
	var random_string:PackedStringArray = []
	for i in 20:
		var byte:int = randi_range(0, 35)
		# "0"-"9" or "A" - "Z"
		random_string.push_back(char( 48 + byte if byte <= 9 else 65 + byte - 10))

	return "".join(random_string)

func refresh_token() -> void:
	log.info("Token refreshed successfully")
	parent.access_token = _create_access_token()
	signals.token_refresh_success.emit()

func get_me() -> void:
	# TODO: User peer id as player id
	signals.user_info_received.emit({username = "player%d" % _player_id})
#endregion


#region Character Management
func create_character(name: String) -> void:
	var id:int = _character_data.size() + 1

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

	_character_data[id] = character_data

	log.success("Character created: %s (ID: %d)" % [character_data.name, character_data.id])
	signals.character_created.emit(character_data)


func get_all_characters(skip: int = 0, limit: int = 10) -> void:
	log.info("Fetched %d characters" % _character_data.size())
	var characters_array = _character_data.values()
	signals.characters_received.emit(characters_array, _character_data.size())

func get_character(character_id: int) -> void:
	if character_id in _character_data:
		var character_data = _character_data[character_id]
		log.info("Fetched character: %s" % character_data.name)
		signals.character_received.emit(character_data)
	else:
		signals.character_not_found.emit()
		log.error("Character not found!")

func update_character(character_id: int, updates: Dictionary) -> void:
	if character_id in _character_data:
		_character_data[character_id] = updates
		log.success("Character updated: %s" % updates.name)
		signals.character_updated.emit(updates)
	else:
		signals.character_not_found.emit()
		log.error("Character not found!")

func delete_character(character_id: int) -> void:
	var deleted:bool = _character_data.erase(character_id)

	if deleted:
		log.success("Character deleted successfully")
		signals.character_deleted.emit()
	else:
		signals.character_not_found.emit()
		log.error("Character not found!")
#endregion


#region Utility
func status() -> void:
	signals.api_status_passed.emit()
#endregion
