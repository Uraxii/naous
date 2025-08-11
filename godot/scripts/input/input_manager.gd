class_name InputManager extends Node

#region Variables
const BACKPEDDLE_PENALTY := 0.75

@onready var signals := Globals.signal_bus

var target_self     := false
var target_next     := false
var target_cancel   := false

var jump := false

var move := Vector2.ZERO
var mouse_move := false

var select_location := false

var camera_look     := false
var camera_rotate   := false
var camera_zoom_out := false
var camera_zoom_in  := false
var camera_rotation := Vector2.ZERO
var mouse_pos_delta := Vector2.ZERO
var curr_mouse_pos  := Vector2.ZERO
var last_mouse_pos  := Vector2.ZERO

var is_ui_visible := false

var actions: Dictionary[String, bool] = {
    "action_0": false
}
#endregion


func get_move_input() -> Vector2:
    var dir: Vector2  = Input.get_vector(
        "move_left", "move_right", "move_forward", "move_back")

    var is_moving_with_mouse = camera_rotate && camera_look
    if is_moving_with_mouse:
        dir.y = -1

    dir = dir.normalized()

    var is_moving_backwards = dir.y > 0
    if is_moving_backwards:
        dir = dir * BACKPEDDLE_PENALTY

    return dir


#region Godot Callback Functions
func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event: InputEvent) -> void:
    if Input.is_action_just_pressed("ui_accept"):
        signals.ui_accept.emit()

    if Input.is_action_just_pressed("ui_cancel"):
        signals.ui_cancel.emit()

    if Input.is_action_just_pressed("ui_toggle"):
        is_ui_visible = not is_ui_visible
        signals.ui_toggle.emit(is_ui_visible)

    move = get_move_input()

    if event is InputEventMouseMotion:
        mouse_pos_delta = Vector2(event.relative.x, event.relative.y)

    target_self = Input.is_action_just_pressed("target_self")
    target_next = Input.is_action_just_pressed("target_next")
    target_cancel = Input.is_action_just_pressed("ui_cancel")

    jump = Input.is_action_just_pressed("jump")

    select_location = Input.is_action_just_pressed("select_location")

    camera_zoom_out = Input.is_action_just_pressed("camera_zoom_out")
    camera_zoom_in = Input.is_action_just_pressed("camera_zoom_in")
    camera_look = Input.is_action_pressed("camera_look")
    camera_rotate = Input.is_action_pressed("camera_rotate")

    mouse_move = camera_look && camera_rotate
    if camera_rotate || camera_look:
        camera_rotation = mouse_pos_delta
    else:
        camera_rotation = Vector2.ZERO

    actions['action_0'] = Input.is_action_just_pressed('action_0')
#endregion

