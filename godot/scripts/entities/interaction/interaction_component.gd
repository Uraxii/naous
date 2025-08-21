class_name InteractionComponent extends Node

@export_category("Detector Dependencies")
@export var entity: Entity
@export var detection_zone: Area3D

@onready var signals := Globals.signal_bus

#region Detector Logic
func detecting_interactable(interactable: InteractableComponent) -> void:
    signals.entity_can_interact.emit(entity, interactable)

#endregion


#region Godot Callback Functions
func _ready() -> void:
    if not is_instance_valid(detection_zone):
        push_error("Expected a detection zone!")
    
    detection_zone.area_entered.connect()

#endregion
