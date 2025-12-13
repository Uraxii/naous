class_name ComponentStat extends Node

signal change(new: float, old: float)

#region Variables
const SPEED_ID      := "Speed"
const HEALTH_ID     := "Health"
const GRAVITY_ID    := "Gravity"
const JUMP_FORCE_ID := "JumpForce"

@export_category("Data Values")
@export var min_value := 0.0 
@export var max_value := 10.0
@export_range(-1.0, 1.0) var start_percent := 1.0  
@export_category("Runtime Values")
@export var is_infinite := false
@export var current: float = 10:
    set = _set_current

@onready var signals := Globals.signal_bus

var percetage: float:
    get: return current/max_value

#endregion

func _ready() -> void:
    current = max_value * start_percent


func _set_current(value: float) -> void:
    if is_infinite:
        return

    var old = current
    current = clamp(value, min_value, max_value)
    change.emit(current, old)
