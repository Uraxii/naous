class_name ComponentHealth extends ComponentStat

signal die


func _set_current(value: float) -> void:
    super._set_current(value)

    if current <= 0:
        die.emit()
