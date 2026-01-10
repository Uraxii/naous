class_name DamageSimple extends EffectBase

## Amount of damage to deal to entities
@export_range(0, 1000, 1) var damage: float = 10

func apply_effect_to_entity(entity: Entity) -> void:
    var health_c: ComponentHealth = entity.health
    if not is_instance_valid(health_c):
        Globals.logger.warn("Damage Effect unable to find health component on entity!")
    else:
        Globals.logger.debug("Dealing damage to entity: Damage=%s | Entity=%s" % [damage, entity.name])
        Globals.signal_bus.play_player_attack.emit()
        health_c.current = health_c.current - damage


func entity_triggered_effect(entity: Entity) -> void:
    if is_instance_valid(entity.targeting):
        var curr_target := entity.targeting.get_current_target()
        if is_instance_valid(curr_target):
            apply_effect_to_entity(curr_target.entity)
