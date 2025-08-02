class_name ApiClientImpl extends Node

var parent:ApiClient

var server:String:
	get: return parent.server
	set(value):
		parent.server = value
		
var access_token:String:
	get: return parent.access_token
	set(value):
		parent.access_token = value

#region Authentication
func login(username: String, password: String) -> void:
	pass

func register(username: String, password: String) -> void:
	pass

func logout() -> void:
	pass

func refresh_token() -> void:
	pass

func get_me() -> void:
	pass
#endregion


#region Character Management
func create_character(name: String) -> void:
	pass
	
func get_all_characters(skip: int = 0, limit: int = 10) -> void:
	pass

func get_character(character_id: int) -> void:
	pass

func update_character(character_id: int, updates: Dictionary) -> void:
	pass

func delete_character(character_id: int) -> void:
	pass
#endregion


#region Utility
func status() -> void:
	pass
#endregion
