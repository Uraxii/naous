class_name InputBindings extends Resource

#region Action Strings
const ACTION_0 := "action_0"
const ACTION_1 := "action_1"
const ACTION_2 := "action_2"
const ACTION_3 := "action_3"
const ACTION_4 := "action_4"
const MOVE_LEFT := "move_left"
const MOVE_RIGHT := "move_right"
const MOVE_FORWARD := "move_forward"
const MOVE_BACK := "move_back"
const JUMP := "jump"
const INTERACT := "interact"
const CAMERA_LEFT := "camera_left"
const CAMERA_RIGHT := "camera_right"
const CAMERA_UP := "camera_up"
const CAMERA_DOWN := "camera_down"
const CAMERA_ZOOM_OUT := "camera_zoom_out"
const CAMERA_ZOOM_IN := "camera_zoom_in"
const CAMERA_ROTATE := "camera_rotate"
const CHARACTER_ROTATE := "character_rotate"
const UI_ACCEPT := "ui_accept"
const UI_CANCEL := "ui_cancel"
const UI_TOGGLE := "ui_toggle"
#endregion

@export var action_0: Array[InputEvent]
@export var action_1: Array[InputEvent]
@export var action_2: Array[InputEvent]
@export var action_3: Array[InputEvent]
@export var action_4: Array[InputEvent]

@export var move_left: Array[InputEvent]
@export var move_right: Array[InputEvent]
@export var move_forward: Array[InputEvent]
@export var move_back: Array[InputEvent]
@export var jump: Array[InputEvent]
@export var interact: Array[InputEvent]

@export var camera_left: Array[InputEvent]
@export var camera_right: Array[InputEvent]
@export var camera_up: Array[InputEvent]
@export var camera_down: Array[InputEvent]
@export var camera_zoom_out: Array[InputEvent]
@export var camera_zoom_in: Array[InputEvent]
@export var camera_rotate: Array[InputEvent]
@export var character_rotate: Array[InputEvent]

@export var ui_accept: Array[InputEvent]
@export var ui_cancel: Array[InputEvent]
@export var ui_toggle: Array[InputEvent]


func get_binds() -> Dictionary:
    return {
        ACTION_0: action_0,
        ACTION_1: action_1,
        ACTION_2: action_2,
        ACTION_3: action_3,
        ACTION_4: action_4,
        MOVE_LEFT: move_left,
        MOVE_RIGHT: move_right,
        MOVE_FORWARD: move_forward,
        MOVE_BACK: move_back,
        JUMP: jump,
        INTERACT: interact,
        CAMERA_LEFT: camera_left,
        CAMERA_RIGHT: camera_right,
        CAMERA_UP: camera_up,
        CAMERA_DOWN: camera_down,
        CAMERA_ZOOM_OUT: camera_zoom_out,
        CAMERA_ZOOM_IN: camera_zoom_in,
        CAMERA_ROTATE: camera_rotate,
        CHARACTER_ROTATE: character_rotate,
        UI_ACCEPT: ui_accept,
        UI_CANCEL: ui_cancel,
        UI_TOGGLE: ui_toggle,
    }
