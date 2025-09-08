class_name InteractableComponent extends Node

signal interaction_started
signal interaction_complete

@export_category("Interaction Dependencies")
@export var entity: Entity ## The owning entity that represents this interactable

@export_category("Interaction Details")
@export var prompt_text: String = "INTERACT WITH ME" ## Text indicating what action occurs when interacting with this object (intended for UI)
@export_range(0, 60, 0.1, "or_greater") var time_to_complete: float = 1.0 ## Time in seconds to complete interaction. 0 will result in the interaction completing immediately
@export_range(1, 5, 0.1, "or_greater") var timer_speed_modifier_per_entity: float = 1.0 ## Multiplier that increases the speed of the timer for each interacting Entity
@export_range(1, 100, 1, "or_greater") var priority: int = 1 ## Higher values have priority over lower values (primarily for UI purposes)
@export var can_resume: bool = false ## If enabled, interaction progress can be paused and resumed. Otherwise will reset when interaction stops.

@onready var signals := Globals.signal_bus

var _interaction_modifier: int = 1


#region Interaction Logic
func interact() -> void:
    #print("Using interactable: ", prompt_text)
    _start_timer()
    interaction_started.emit()


func stop_interaction() -> void:
    _stop_timer()


func complete_interaction() -> void:
    #print("Completing usage of interactable: ", prompt_text)
    interaction_complete.emit()
    _stop_timer()


## Get the current interaction progress as a ratio of the total time needed to complete the interaction. Ranges from 0.0 (not started) to 1.0 (fully completed).
func get_current_interaction_progress() -> float:
    return snappedf(_curr_time / time_to_complete, 0.00001) # Round to 5th decimal place (arbitrary, adjust as needed)


func is_higher_priority_than(interactable: InteractableComponent) -> bool:
    return priority > interactable.priority
#endregion


#region Timer Setup
var _timer_is_running: bool = false
var _curr_time: float = 0.0
func _timer_tick(delta: float) -> void:
    if _timer_is_running:
        _curr_time += delta * timer_speed_modifier_per_entity
        if _curr_time >= time_to_complete:
            complete_interaction()


func _start_timer() -> void:
    _timer_is_running = true


func _stop_timer() -> void:
    _timer_is_running = false
    if not can_resume:
        _curr_time = 0.0


func increase_interaction_modifier() -> void:
    _interaction_modifier += 1


func decrease_interaction_modifier() -> void:
    _interaction_modifier = max(_interaction_modifier - 1, 1) # Can't go lower than 1
#endregion


#region Godot Callback Functions
func _ready() -> void:
    pass


func _process(delta: float) -> void:
    _timer_tick(delta)
#endregion
