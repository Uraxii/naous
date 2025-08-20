class_name InteractableComponent extends Node

@export var prompt_text: String = "INTERACT WITH ME" ## Indicates what action occurs when interacting with this object (intended for UI)
@export_range(0, 60, 0.1) var interaction_time: float = 1.0 ## Time in seconds to complete interaction
@export_range(1, 100, 1) var priority: int = 1 ## Higher values have priority over lower values
@export var can_resume: bool = false ## If enabled, interaction progress can be paused and resumed. Otherwise will reset when interaction stops.

@onready var signals := Globals.signal_bus

var interaction_timer: Timer


#region Interaction Logic
func begin_interaction() -> void:
    if not interaction_timer.is_stopped() and not interaction_timer.paused:
        interaction_timer.start()


func stop_interaction() -> void:
    pass


func _trigger_interaction() -> void:
    signals.entity_interacted.emit()
#endregion


#region Godot Callback Functions
func _ready() -> void:
    interaction_timer = Timer.new()
    interaction_timer.one_shot = true
    interaction_timer.wait_time = interaction_time
    add_child(interaction_timer)

#endregion
