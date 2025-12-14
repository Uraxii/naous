class_name ComponentStat extends Node

signal change(new: float, old: float)

#region Variables
const SPEED_ID      := "Speed"
const HEALTH_ID     := "Health"
const GRAVITY_ID    := "Gravity"
const JUMP_FORCE_ID := "JumpForce"

@export var is_invincible := false
@export var current: float = 10:
    set = _set_current
@export var min_value := 0.0 
@export var max_value := 100.0

@onready var signals := Globals.signal_bus

var percetage: float:
    get: return current/max_value

#endregion


func _set_current(value: float) -> void:
    if is_invincible:
        return

    var old = current
    current = clamp(value, min_value, max_value)
    change.emit(current, old)
