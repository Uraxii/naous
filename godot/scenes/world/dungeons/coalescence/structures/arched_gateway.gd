class_name ArchedGateway extends Node3D

@onready var rubble_entity: Entity = %Boulder


func remove_rubble() -> void:
    # This will remove the node from the tree without deleting it entirely
    remove_child(rubble_entity)


func delete_rubble() -> void:
    # make sure this only happence once
    if rubble_entity and is_instance_valid(rubble_entity):
        rubble_entity.queue_free()
