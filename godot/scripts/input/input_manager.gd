class_name InputManager extends Node

#region Variables
@onready var signals := Globals.signal_bus
@onready var action_map: Dictionary[String, Signal] = {
    InputBindings.ACTION_0: signals.action_0,
    InputBindings.ACTION_1: signals.action_1,
    InputBindings.ACTION_2: signals.action_2,
}

var default_binds: InputBindings = load(
    "res://resources/default_input_bindings.tres")

var move: Vector2:
    get: return Input.get_vector(
        InputBindings.MOVE_LEFT,
        InputBindings.MOVE_RIGHT,
        InputBindings.MOVE_FORWARD,
        InputBindings.MOVE_BACK)

var joystick_camera: Vector2:
    get: return Input.get_vector(
        InputBindings.CAMERA_LEFT,
        InputBindings.CAMERA_RIGHT,
        InputBindings.CAMERA_UP,
        InputBindings.CAMERA_DOWN)

var jump := false
var select_location := false
var mouse_pos_delta := Vector2.ZERO


#endregion


func update_binds(new_binds: InputBindings) -> void:
    var binds = new_binds.get_binds()
    
    for action in binds.keys():
        InputMap.erase_action(action)
        InputMap.add_action(action)
        
        for event in binds[action]:
            InputMap.action_add_event(action, event)
        
        print_debug(InputMap.action_get_events(action))
    

#region Godot Callback Functions
func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    update_binds(default_binds)


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        signals.rotate_camera.emit(Vector2(event.relative.x, event.relative.y))
        return

    if Input.is_action_just_pressed("camera_zoom_out"):
        signals.camera_zoom_out.emit()

    if Input.is_action_just_pressed("camera_zoom_in"):
        signals.camera_zoom_in.emit()

    if Input.is_action_just_pressed("jump"):
        signals.jump.emit()

    if Input.is_action_just_pressed("ui_accept"):
        signals.ui_accept.emit()

    if Input.is_action_just_pressed("ui_cancel"):
        signals.ui_cancel.emit()

    if Input.is_action_just_pressed("ui_toggle"):
        signals.ui_toggle.emit()

    if Input.is_action_just_pressed("ui_cancel"):
        signals.ui_cancel.emit()

    for action in action_map.keys():
        if Input.is_action_just_pressed(action):
            action_map[action].emit()
#endregion
