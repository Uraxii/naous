class_name Door extends Node3D

@export_category("Door Details")
@export var open_rotation: Vector3
@export var close_rotation: Vector3

@onready var component_manager: ComponentManager = %ComponentManager

var is_open: bool = false

#region Door Logic
func toggle_position() -> void:
    if is_open:
        close()
    else:
        open()


func open() -> void:
    _animate_rotation_to(open_rotation)
    is_open = true


func close() -> void:
    _animate_rotation_to(close_rotation)
    is_open = false


func _animate_rotation_to(rotation_vector: Vector3) -> void:
    # TODO: Tween/AnimationPlayer this
    rotation = rotation_vector
#endregion


#region Godot Callback Functions
func _ready() -> void:
    var interactable_component: InteractableComponent = component_manager.get_component(InteractableComponent) as InteractableComponent
    

#endregion
