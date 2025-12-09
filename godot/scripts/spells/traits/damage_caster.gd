class_name DamageCaster extends Trait

@export var damage := 10.0


func cast() -> void:
    var health = spell.caster.health
    if health:
        health.current -= damage 
