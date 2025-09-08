class_name MinDistanceRequirement extends InteractableRequirement

## The minimum distance the player must be to the Interactable to interact with it
@export_range(0.0, 100.0, 0.2, "or_greater") var min_distance: float = 10.0


# If the entity is close enough to the owning interactable, the condition passes.
func condition_passed(entity: Entity) -> bool:
    var entity_distance_to_interactable := entity.body.global_position.distance_to(parent_interactable.entity.body.global_position)
    return entity_distance_to_interactable <= min_distance
