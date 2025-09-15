class_name DamageTarget extends Node

@export var amount := 1.0
@onready var signals := Globals.signal_bus

var spell: Spell
var caster: Entity


func setup() -> void:
    spell = get_parent()


func cast() -> void:
    var target := spell.caster.target
    if not target:
        lg.debug("No target")
        return

    signals.damage_entity.emit(target.id, amount)
