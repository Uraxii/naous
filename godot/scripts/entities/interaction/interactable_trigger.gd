class_name InteractableTrigger extends Area3D

@export var interactable: InteractableComponent


func _ready() -> void:
    #monitoring = false
    collision_layer = (1 << InteractionManager.INTERACTABLE_COLLISION_LAYER - 1)
    #collision_mask = 0
