class_name InputManager extends Node

#region Variables
@onready var signals := Globals.signal_bus
@onready var lg := Globals.logger
@onready var action_map: Dictionary[String, Signal] = {
    InputBindings.CAMERA_ZOOM_IN: signals.camera_zoom_in,
    InputBindings.CAMERA_ZOOM_OUT: signals.camera_zoom_out,
    InputBindings.JUMP: signals.jump,
    InputBindings.INTERACT: signals.interact,
    InputBindings.UI_ACCEPT: signals.ui_accept,
    InputBindings.UI_CANCEL: signals.ui_cancel,
    InputBindings.UI_TOGGLE: signals.ui_toggle,
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

var was_camera_rotating := false
var was_character_rotating := false
var was_camera_move_enabled := false
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
        
        # print_debug(InputMap.action_get_events(action))
    

#region Godot Callback Functions
func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    update_binds(default_binds)


func _input(event: InputEvent) -> void:
    var rotate_cam = Input.is_action_pressed(InputBindings.CAMERA_ROTATE)
    var rotate_char =  Input.is_action_pressed(InputBindings.CHARACTER_ROTATE)
    var is_camera_rotating = rotate_cam or rotate_char
    
    if was_camera_rotating and not is_camera_rotating:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    elif not was_camera_rotating and is_camera_rotating:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        
    if rotate_char and not was_character_rotating:
        signals.character_rotate_start.emit()
    elif not rotate_char and was_character_rotating:
        signals.character_rotate_stop.emit()
    
    was_camera_rotating = is_camera_rotating
    was_character_rotating = rotate_char
    was_camera_move_enabled = rotate_cam and rotate_char
    
    if event is InputEventMouseMotion:
        var move_delta = Vector2(event.relative.x, event.relative.y)
        if is_camera_rotating:
            signals.camera_rotate.emit(move_delta)

    # TODO: Controller has hotbutton binds set 1:1 with regular button inputs.
    #       Depending on how many hotkey actions are expected to be available, we may need to
    #       change that to a modifier system to give the player easy access to more actions.
    #       - eg. LT + Face buttons for a set of actions, RT + face buttons for another set
    for action in action_map.keys():
        if Input.is_action_just_pressed(action):
            lg.debug("Pressed:", action)
            action_map[action].emit()
#endregion
