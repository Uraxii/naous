class_name StarterGearPickup
extends Node3D

signal collected

@onready var starter_gear_entity: Entity = $StarterGearEntity


func _on_interaction_complete() -> void:
    print("Starter Gear Collected!")
    collected.emit()


func _ready() -> void:
    var interactable_c: InteractableComponent = starter_gear_entity.components.find("Interactable")
    interactable_c.interaction_complete.connect(_on_interaction_complete)
