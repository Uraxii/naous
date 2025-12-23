class_name DamageTarget extends Trait

@onready var signals := Globals.signal_bus
@onready var entities := Globals.entities

var caster: Entity


func cast() -> void:
    var target: Entity = entities.find(spell.caster.target_id)
    if not target:
        lg.debug("No target")
        return

    if target.health:
        target.health.current -= data.damage
