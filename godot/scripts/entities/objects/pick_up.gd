class_name PickUp extends Entity


func initiate_pick_up() -> void:
    print("Starting to pick up the pick-up-able object!")


func complete_pick_up() -> void:
    print("Picked up the pick-up-able object!")


func _ready() -> void:
    super._ready()
    var interactable_component: InteractableComponent = components.find("Interactable")
    interactable_component.interaction_complete.connect(complete_pick_up)
