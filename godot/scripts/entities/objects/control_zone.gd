class_name ControlZone extends Entity

func start_control() -> void:
    print("Player is controlling the zone!")


func control_complete() -> void:
    print("Player has captured the zone!")


func _ready() -> void:
    var interactable_component: InteractableComponent = get_component(InteractableComponent) as InteractableComponent
    interactable_component.interaction_started.connect(start_control)
    interactable_component.interaction_complete.connect(control_complete)
