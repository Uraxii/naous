class_name ComponentHealth extends ComponentStat

signal die


func _set_current(value: float) -> void:
    if is_infinite:
        return

    var old = current
    current = clamp(value, min_value, max_value)
    change.emit(current, old)

    if value <= 0:
        die.emit()
