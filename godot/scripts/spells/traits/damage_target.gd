class_name DamageTarget extends Trait

@onready var signals := Globals.signal_bus
func cast() -> void:
    var target := spell.target_entity
    if not target:
        lg.debug("No target")
        return

    if target.health:
        target.health.current -= data.damage
