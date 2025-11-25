class_name ArchedGateway extends Node3D

@onready var rubble_entity: Entity = %RubbleEntity


func remove_rubble() -> void:
    # This will remove the node from the tree without deleting it entirely
    remove_child(rubble_entity)


func delete_rubble() -> void:
    rubble_entity.queue_free()
