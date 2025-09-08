class_name InteractionComponent extends Node

signal can_interact_with(interactable: InteractableComponent)
signal started_interaction_with(interactable: InteractableComponent)
signal interrupted_interaction_with(interactable: InteractableComponent)
signal completed_interaction_with(interactable: InteractableComponent)
signal lost_interactable(interactable: InteractableComponent)

@export_category("Detector Dependencies")
@export var entity: Entity
@export var detection_zone: InteractableDetector

@onready var signals := Globals.signal_bus

var current_interactables: Array[InteractableComponent]


#region Interaction Logic
func attempt_highest_priority_interaction() -> void:
    #print("Attempting to interact with highest priority object!")
    var target_interactable := get_highest_priority_detected_interactable()
    if target_interactable != null:
        attempt_interaction_with(target_interactable)


func attempt_interaction_with(interactable: InteractableComponent) -> void:
    #print("Attempting to interact with: ", interactable.prompt_text)
    signals.entity_attempting_interaction.emit(entity, interactable)


func start_interaction_with(interactable: InteractableComponent) -> void:
    #print("Starting interaction with: ", interactable.prompt_text)
    add_current_interactable(interactable)
    started_interaction_with.emit(interactable)
    signals.entity_started_interaction.emit(entity, interactable)


func interrupt_interaction_with(interactable: InteractableComponent) -> void:
    #print("Interrupting interaction with: ", interactable.prompt_text)
    if current_interactables.has(interactable):
        interrupted_interaction_with.emit(interactable)
        signals.entity_interaction_interrupted.emit(entity, interactable)
        remove_current_interactable(interactable)


func complete_interaction_with(interactable: InteractableComponent) -> void:
    #print("Completed interaction with: ", interactable.prompt_text)
    completed_interaction_with.emit(interactable)
    signals.entity_completed_interaction.emit(entity, interactable)
    remove_current_interactable(interactable)


# TODO: This should probably be refactored to a "targeting" system when we get that started
func get_highest_priority_detected_interactable() -> InteractableComponent:
    var priority_interactable: InteractableComponent # will be null there are none detected
    
    # First see if we're targeting something and prioritize that
    if is_instance_valid(entity.targeting) and entity.targeting.has_valid_target():
        var current_targetable := entity.targeting.current_target
        var current_target_entity := current_targetable.entity
        priority_interactable = current_target_entity.components.find("Interactable")
    
    # Check what interactacles we are detecting and attempt to interact with the highest priority one (and target it if possible)
    else:
        var detected_interactables := detection_zone.detected_interactables
        
        if detected_interactables != null and not detected_interactables.is_empty():
            # If there's only one interactable, just grab it
            if detected_interactables.size() == 1:
                priority_interactable = detected_interactables[0]
            
            # Find the Interactable with the highest priority
            else:
                priority_interactable = detected_interactables.pop_back() # start with the last one and reduce the array size
                for interactable: InteractableComponent in detected_interactables:
                    if interactable.is_higher_priority_than(priority_interactable):
                        priority_interactable = interactable
            
            # Attempt to target this interactable since we're interacting with it
            if is_instance_valid(priority_interactable) and is_instance_valid(entity.targeting):
                var interactable_entity := priority_interactable.entity
                var interactable_target := interactable_entity.components.find("Targetable")
                if interactable_target != null:
                    entity.targeting.set_current_target(interactable_target)
    
    return priority_interactable


func add_current_interactable(new_interactable: InteractableComponent) -> void:
    if not current_interactables.has(new_interactable):
        current_interactables.push_back(new_interactable)
        if not new_interactable.interaction_complete.is_connected(complete_interaction_with):
            new_interactable.interaction_complete.connect(complete_interaction_with.bind(new_interactable))


func remove_current_interactable(interactable_to_remove: InteractableComponent) -> void:
    if current_interactables.has(interactable_to_remove):
        current_interactables.erase(interactable_to_remove)
        if interactable_to_remove.interaction_complete.is_connected(complete_interaction_with):
            interactable_to_remove.interaction_complete.disconnect(complete_interaction_with)


func _on_detecting_interactable(interactable: InteractableComponent) -> void:
    #print("Can interact with: ", interactable.prompt_text)
    can_interact_with.emit(interactable)
    signals.entity_detected_interactable.emit(entity, interactable)


func _on_lost_interactable(interactable: InteractableComponent) -> void:
    lost_interactable.emit(interactable)
    signals.entity_lost_interactable.emit(entity, interactable)
    remove_current_interactable(interactable)
#endregion


#region Godot Callback Functions
func _ready() -> void:
    signals.interact.connect(attempt_highest_priority_interaction)
    
    if not is_instance_valid(detection_zone):
        push_error("Expected a detection zone!")
    
    detection_zone.detecting_interactable.connect(_on_detecting_interactable)
    detection_zone.lost_interactable.connect(_on_lost_interactable)
#endregion
