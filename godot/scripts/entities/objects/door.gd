class_name Door extends Entity

@export_category("Door Details")
@export var open_rotation: Vector3
@export var close_rotation: Vector3

var is_open: bool = false


#region Door Logic
func toggle_position() -> void:
    if is_open:
        close()
    else:
        open()


func open() -> void:
    print("Door opening!")
    _rotate_to(open_rotation)
    is_open = true


func close() -> void:
    print("Door closing!")
    _rotate_to(close_rotation)
    is_open = false


func _rotate_to(rotation_vector: Vector3) -> void:
    # TODO: Tween/AnimationPlayer this
    rotation = rotation_vector
#endregion


#region Godot Callback Functions
func _ready() -> void:
    super._ready()
    var interactable_component: InteractableComponent = components.find("Interactable")
    interactable_component.interaction_complete.connect(toggle_position)
#endregion
