class_name InteractableRequirement extends Resource

var parent_interactable: InteractableComponent

## Returns 'true' if the requirement has been met for this Interactable, 'false' otherwise.
# Should be overridden by implementing classes.
func condition_passed(entity: Entity) -> bool:
    return true


func _init() -> void:
    resource_local_to_scene = true
