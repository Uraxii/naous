class_name TargetingSystem extends Node

@export var cursor_targeting: CursorTargeting
@export var auto_targeting: AutoTargeting
@export var scan_targeting: ScanTargeting

@onready var signals := Globals.signal_bus

var current_target: Targetable:
    set = _set_current_target


#region Targeting
func cursor_target() -> void:
    #print("Attempting CURSOR target!")
    var cursor_detection_target := cursor_targeting.get_next_detected_target(current_target)
    if is_instance_valid(cursor_detection_target) and cursor_detection_target != current_target:
        #print("CURSOR TARGET: updating current target!")
        current_target = cursor_detection_target


func next_target() -> void:
    #print("attempting NEXT auto target!")
    var next_auto_target := auto_targeting.get_next_detected_target(current_target)
    if is_instance_valid(next_auto_target) and next_auto_target != current_target:
        #print("AUTO NEXT TARGET: updating current target!")
        current_target = next_auto_target


func previous_target() -> void:
    #print("attempting PREV auto target!")
    var prev_auto_target := auto_targeting.get_previous_detected_target(current_target)
    if is_instance_valid(prev_auto_target) and prev_auto_target != current_target:
        #print("AUTO PREV TARGET: updating current target!")
        current_target = prev_auto_target


func scan_target_right() -> void:
    print("attempting RIGHT scan target!")
    var next_scan_target := scan_targeting.get_next_detected_target(current_target)
    if is_instance_valid(next_scan_target) and next_scan_target != current_target:
        #print("SCAN NEXT TARGET: updating current target!")
        current_target = next_scan_target


func scan_target_left() -> void:
    print("attempting LEFT scan target!")
    var prev_scan_target := scan_targeting.get_previous_detected_target(current_target)
    if is_instance_valid(prev_scan_target) and prev_scan_target != current_target:
        #print("SCAN PREV TARGET: updating current target!")
        current_target = prev_scan_target


func cancel_target() -> void:
    current_target = null


func has_valid_target() -> bool:
    return is_instance_valid(current_target)


func _set_current_target(new_target) -> void:
    if is_instance_valid(current_target):
        current_target.hide_indicator()
    
    current_target = new_target
    
    if is_instance_valid(current_target):
        print("setting new current target to: ", new_target.get_parent().get_parent().name)
        current_target.show_indicator()
#endregion


#region Godot Callbacks
func _ready() -> void:
    signals.cursor_target.connect(cursor_target)
    signals.next_target.connect(next_target)
    signals.previous_target.connect(previous_target)
    signals.scan_target_right.connect(scan_target_right)
    signals.scan_target_left.connect(scan_target_left)
    signals.cancel_target.connect(cancel_target)
#endregion
