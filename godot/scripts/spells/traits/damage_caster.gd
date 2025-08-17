class_name DamageCaster extends Node

@export var damage := 10.0

@onready var spell: Spell


func setup() -> void:
    spell = get_parent()


func cast() -> void:
    var target = spell.caster
    var health = target.get_stat("Health")
    health.current -= damage
