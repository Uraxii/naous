class_name TargetingDetection extends Node

enum TARGETING_INPUTS { 
    CURSOR_TARGET = InputBindings.CURSOR_TARGET
    #NEXT_TARGET: next_target,
    #PREVIOUS_TARGET: previous_target,
    #SCAN_TARGET_RIGHT: scan_target_right,
    #SCAN_TARGET_LEFT: scan_target_left,
}
@export var inputs: TARGETING_INPUTS
@export var detectors: Array[TargetDetector]


func process_and_find_target(event: InputEvent) -> void:
    pass


func can_process_event(event: InputEvent) -> bool:
    return false
