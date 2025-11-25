class_name DamageSimple extends EffectBase

## Amount of damage to deal to entities
@export_range(0, 1000, 1) var damage: float = 10

func apply_effect_to_entity(entity: Entity) -> void:
    var health_c: HealthComponent = entity.health
    if not is_instance_valid(health_c):
        Globals.logger.warn("Damage Effect unable to find health component on entity!")
    else:
        Globals.logger.debug("Dealing damage to entity: Damage=%s | Entity=%s" % [damage, entity.name])
        health_c.current = health_c.current - damage
