class_name LootPickup
extends Node3D

signal collected

@export var loot_entity: Entity


func _on_interaction_complete() -> void:
    print("Loot Collected!")
    collected.emit()


func _ready() -> void:
    var interactable_c: InteractableComponent = loot_entity.components.find("Interactable")
    interactable_c.interaction_complete.connect(_on_interaction_complete)
