class_name StatComponent extends Node

signal change(new: float, old: float)

#region Variables
@export_category("Data Values")
@export var start_value := 1.0  
@export var min_value := 0.0 
@export var max_value := 10.0
@export_category("Runtime Values")
@export var is_infinite := false

@onready var current: float = start_value: set = _set_current

var signals: SignalBus:
    get: return Globals.signal_bus
#endregion


func _set_current(value: float) -> void:
    if is_infinite:
        return
        
    var old = current
    current = clamp(value, min_value, max_value)
    change.emit(current, old)
