class_name InteractableComponent extends Node

@export_category("Interaction Dependencies")
@export var entity: Entity
@export var trigger_zone: Area3D

@export_category("Interaction Details")
@export var prompt_text: String = "INTERACT WITH ME" ## Indicates what action occurs when interacting with this object (intended for UI)
@export_range(0, 60, 0.1, "or_greater") var interaction_time: float = 1.0 ## Time in seconds to complete interaction
@export_range(1, 100, 1, "or_greater") var priority: int = 1 ## Higher values have priority over lower values (primarily for UI purposes)
@export var can_resume: bool = false ## If enabled, interaction progress can be paused and resumed. Otherwise will reset when interaction stops.
@export var initiate_on_detection: bool = false ## If enabled, will automatically initate interaction when the zone detects an object. Otherwise interaction must be manually initiated.

@onready var signals := Globals.signal_bus

var interaction_timer: Timer


#region Interaction Logic
func interact() -> void:
    if is_instance_valid(interaction_timer):
        if can_resume:
            interaction_timer.paused = false
        elif not interaction_timer.is_stopped():
            interaction_timer.start()


func stop_interaction() -> void:
    if is_instance_valid(interaction_timer):
        if can_resume:
            interaction_timer.paused = true
        else:
            interaction_timer.stop()


func _trigger_interaction() -> void:
    signals.entity_interacted.emit()
#endregion


#region Timer Setup
func _provision_interaction_timer() -> Timer:
    var new_timer := Timer.new()
    new_timer.one_shot = true
    new_timer.wait_time = interaction_time
    return new_timer
#endregion


#region Godot Callback Functions
func _ready() -> void:
    if interaction_time > 0.0:
        interaction_timer = _provision_interaction_timer()
        add_child(interaction_timer)
#endregion
