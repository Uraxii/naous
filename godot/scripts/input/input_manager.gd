class_name InputManager extends Node

@onready var signals := Globals.signal_bus

var target_self     := false
var target_next     := false
var target_cancel   := false

var jump := false

var move := Vector2.ZERO
var mouse_move := false

var select_location := false

var camera_look_enabled     := false
var camera_rotation_enabled := false
var camera_zoom_out         := false
var camera_zoom_in          := false
var camera_rotation         := Vector2.ZERO
var mouse_motion_delta      := Vector2.ZERO
var current_mouse_position  := Vector2.ZERO
var previous_mouse_position := Vector2.ZERO

var toggle_ui := false

var actions: Dictionary = {
    "bar_1_skill_1": func() -> bool:
            return Input.is_action_just_pressed("bar_1_skill_1"),

    "bar_1_skill_2": func() -> bool:
            return Input.is_action_just_pressed("bar_1_skill_2"),
}


func is_move_event(event: InputEvent) -> bool:
    var forward := event.is_action("move_forward")
    var left := event.is_action("move_left")
    var back := event.is_action("move_back")
    var right := event.is_action("move_right")
    return forward or left or back or right


func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event: InputEvent) -> void:
    if Input.is_action_just_pressed("ui_accept"):
        signals.in_accept.emit()
    if Input.is_action_just_pressed("ui_cancel"):
        signals.in_cancel.emit()
    if Input.is_action_just_pressed("ui_toggle"):
        signals.toggle_ui.emit()
    if is_move_event(event):
        _move_input()
        
    if event is InputEventMouseMotion:
        mouse_motion_delta = Vector2(event.relative.x, event.relative.y)    

    target_self = Input.is_action_just_pressed("target_self")
    target_next = Input.is_action_just_pressed("target_next")
    target_cancel = Input.is_action_just_pressed("ui_cancel")
    
    jump = Input.is_action_just_pressed("jump")

    select_location = Input.is_action_just_pressed("select_location")

    camera_zoom_out = Input.is_action_just_pressed("camera_zoom_out")
    camera_zoom_in = Input.is_action_just_pressed("camera_zoom_in")
    camera_look_enabled = Input.is_action_pressed("camera_look_enabled")
    camera_rotation_enabled = Input.is_action_pressed("camera_rotate_enabled")

    if camera_rotation_enabled || camera_look_enabled:
            camera_rotation = mouse_motion_delta
    else:
            camera_rotation = Vector2.ZERO


func _move_input():
    var dir: Vector2  = Input.get_vector(
        "move_left", "move_right", "move_forward", "move_back")

    mouse_move = camera_rotation_enabled && camera_look_enabled

    if mouse_move && dir.y == 0:
            dir.y = -1

    dir = dir.normalized()
    signals.in_move.emit(dir)
