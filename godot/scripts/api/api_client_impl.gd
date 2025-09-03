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
func login(_username: String, _password: String) -> void:
    pass

func register(_username: String, _password: String) -> void:
    pass

func logout() -> void:
    pass

func refresh_token() -> void:
    pass

func get_me() -> void:
    pass
#endregion


#region Utility
func status() -> void:
    pass
#endregion
