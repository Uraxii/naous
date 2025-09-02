class_name StateCameraFree extends State

@onready var camera: CameraManager = get_owner()

var input: InputManager:
    get: return Globals.input


func enter() -> void:
    next_state = StateCameraFree


func process() -> void:
    if camera.target:
        next_state = StateCameraFollow


func exit() -> void:
    pass
