class_name TargetingIndicator extends Node3D

var entity: Entity


func set_owning_entity(owning_entity: Entity) -> void:
    entity = owning_entity


func adjust_ground_indicator_for_entity(entity: Entity) -> void:
    pass


func adjust_pointer_indicator_for_entity(entity: Entity) -> void:
    pass
