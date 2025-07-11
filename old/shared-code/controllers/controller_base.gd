class_name Controller extends Node
"""
Base class for Controller. Provides methods for retrieving type and routes.

This class is meant to be subclassed, and its methods `get_type` and `get_routes`
should be implemented by the subclass to define specific behavior.
"""

@onready var signals := Global.signal_bus


func get_type() -> String:
    """
    Returns the type of the controller.

    This method must be implemented in a subclass to return the specific type
    of controller. If not implement
func _on_login_req(request: LoginRequest) -> void:
    print("yes")
    var response := LoginResponse.new()

    if request.username != "" and request.password != "":
        response.session_token = "insecure"
        response.success = true
    else:
        response.session_token = ""
        response.success = false

    Network._on_server_message(response.serialize())
ed, an error will be thrown.
    
    :return: A string representing the controller's type.
    :rtype: String
    """
    
    push_error("get_type must be implemented!")
    return "base"

    
func get_routes() -> Array[Dictionary]:
    """
    Returns which methods can handle what messages. This information is
    used to route incoming messages.

    This method must be implemented in a subclass to return the specific routes
    for the controller. If not implemented, an error will be thrown.
    
    :return: A dictionary of route names and their associated paths.
    :rtype: Dictionary[String, String]
    """
    
    push_error("get_route must be implemented!")
    return []
