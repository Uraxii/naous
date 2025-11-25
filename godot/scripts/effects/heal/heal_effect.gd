class_name HealEffect extends EffectBase

@export_range(0, 1000, 1) var amount: float = 500


func apply_effect_to_entity(entity: Entity) -> void:
    if is_instance_valid(entity.health):
        Globals.logger.debug("Healing entity!")
        entity.health.current = entity.health.current + amount


func entity_triggered_effect(entity: Entity) -> void:
    apply_effect_to_entity(entity)
