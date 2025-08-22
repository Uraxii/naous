class_name InteractableDetector extends Area3D

signal detecting_interactable(interactable: InteractableComponent)
signal lost_interactable(interactable: InteractableComponent)

var detected_interactables: Array[InteractableComponent]


#region Detection Logic
func is_detecting_interactable(interactable: InteractableComponent) -> bool:
    return detected_interactables.has(interactable)


func add_detected_interactable(new_interactable: InteractableComponent) -> void:
    if not detected_interactables.has(new_interactable):
        detected_interactables.push_back(new_interactable)
        detecting_interactable.emit(new_interactable)
    else:
        push_error("Can't add interactable that is already detected!")


func remove_detected_interactable(interactable_to_remove: InteractableComponent) -> void:
    if detected_interactables.has(interactable_to_remove):
        detected_interactables.erase(interactable_to_remove)
        lost_interactable.emit(interactable_to_remove)
    else:
        print("Can't remove Interactable that is not currently detected! Might be OK?")
#endregion


#region Godot Callbacks
func _ready() -> void:
    #monitorable = false
    #collision_layer = false
    collision_mask = (1 << InteractionManager.INTERACTABLE_COLLISION_LAYER - 1)
    area_entered.connect(_on_interactable_trigger_detected)
    area_exited.connect(_on_interactable_trigger_lost)


func _on_interactable_trigger_detected(area: Area3D) -> void:
    var trigger: InteractableTrigger = area as InteractableTrigger
    if trigger != null:
        var interactable := trigger.interactable
        add_detected_interactable(interactable)


func _on_interactable_trigger_lost(area: Area3D) -> void:
    var trigger: InteractableTrigger = area as InteractableTrigger
    var interactable := trigger.interactable
    remove_detected_interactable(interactable)
#endregion
