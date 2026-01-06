class_name Door extends Entity

@export_category("Door Details")
@export_range(-360, 360, 1) var rotation_amount: float = 90.0 ## Amount and direction (via +/-) in degress to rotate
@export var start_open: bool = false

var is_open: bool = false

var _initial_rotation: Vector3


#region Door Logic
func toggle_position() -> void:
    if is_open:
        close()
    else:
        open()


func open() -> void:
    #print("Door opening!")
    _rotate_to(_initial_rotation.y + rotation_amount)
    is_open = true


func close() -> void:
    #print("Door closing!")
    _rotate_to(_initial_rotation.y)
    is_open = false


func _rotate_to(rotation_angle_deg: float) -> void:
    # TODO: Tween/AnimationPlayer this
    rotation_degrees.y = rotation_angle_deg
#endregion


#region Godot Callback Functions
func _ready() -> void:
    super._ready()
    var interactable_component: InteractableComponent = components.find("Interactable")
    interactable_component.interaction_complete.connect(toggle_position)
    
    _initial_rotation = rotation_degrees
    if start_open:
        _rotate_to(_initial_rotation.y + rotation_amount)
#endregion
