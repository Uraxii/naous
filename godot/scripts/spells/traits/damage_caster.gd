class_name DamageCaster extends Trait

func cast() -> void:
    var health = spell.caster.health
    if health:
        health.current -= data.damage
