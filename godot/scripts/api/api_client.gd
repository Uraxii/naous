class_name ApiClient extends Node

var server: String = "http://localhost:8080"
var access_token: String = ""

var delegate: ApiClientImpl:
    set(value):
        if not value:
            assert("ApiClient(%s): delegate cannot be null" % name)
            return
        if delegate:
            remove_child(delegate)
            delegate.queue_free()
        value.parent = self
        delegate = value
        add_child(delegate)
    get: return delegate


func _ready() -> void:
    if not delegate:
        delegate = HttpApiClientImpl.new()


func set_server(protocol: String, address: String, port: int) -> void:
    server = "%s://%s:%d" % [protocol, address, port]

#region Authentication
func login(username: String, password: String) -> void:
    delegate.login(username, password)


func register(username: String, password: String) -> void:
    delegate.register(username, password)


func logout() -> void:
    delegate.logout()


func refresh_token() -> void:
    delegate.refresh_token()


func get_me() -> void:
    delegate.get_me()
#endregion


#region Character Management
func create_character(display_name: String) -> void:
    delegate.create_character(display_name)


func get_all_characters(skip: int = 0, limit: int = 10) -> void:
    delegate.get_all_characters(skip, limit)


func get_character(character_id: int) -> void:
    delegate.get_character(character_id)


func update_character(character_id: int, updates: Dictionary) -> void:
    delegate.update_character(character_id, updates)


func delete_character(character_id: int) -> void:
    delegate.delete_character(character_id)
#endregion

#region Utility
func status() -> void:
    delegate.status()
#endregion
