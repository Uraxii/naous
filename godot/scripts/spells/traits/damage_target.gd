class_name DamageTarget extends Node

@export var amount := 10.0

@onready var signals := Globals.signal_bus
@onready var entities := Globals.entities

var spell: Spell
var caster: Entity


func setup() -> void:
    spell = get_parent()


func cast() -> void:
    var target := entities.find(spell.caster.target_id)
    if not target:
        lg.debug("No target")
        return

    if target.health:
        target.health.current -= amount
