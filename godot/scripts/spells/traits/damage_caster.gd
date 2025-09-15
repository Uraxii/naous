class_name DamageCaster extends Node

@export var damage := 10.0

var spell: Spell


func setup() -> void:
    spell = get_parent()


func cast() -> void:
    var health = spell.caster.health
    if health:
        health.current -= damage 
