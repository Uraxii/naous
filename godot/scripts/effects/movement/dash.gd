class_name DashEffect extends EffectBase

@export_range(0, 100, .1) var speed_modifier: float = 3.0
@export_range(0, 60, 1) var effect_time: float = 0.5


func apply_effect_to_entity(entity: Entity) -> void:
    var speed_c: StatComponent = entity.speed
    if not is_instance_valid(speed_c):
        Globals.logger.error("Dash Effect can't find speed component of entity!")
        return
    
    var original_speed := speed_c.current
    speed_c.current = speed_c.current * speed_modifier
    entity.get_tree().create_timer(effect_time).timeout.connect(
        _on_effect_end.bind(entity, original_speed)
    )


func entity_triggered_effect(entity: Entity) -> void:
    apply_effect_to_entity(entity)


func _on_effect_end(affected_entity: Entity, original_speed: float) -> void:
    var speed_c: StatComponent = affected_entity.speed
    speed_c.current = original_speed
