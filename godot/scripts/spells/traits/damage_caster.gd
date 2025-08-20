class_name DamageCaster extends Node

@export var damage := 10.0
@onready var spell: Spell


func setup() -> void:
    spell = get_parent()


func cast() -> void:
    var stats = spell.caster.get_component(StatComponent)
    if stats:
        var health = stats.get_stat("Health")
        health.current -= damage
