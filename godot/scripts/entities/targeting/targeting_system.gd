class_name TargetingSystem extends Node

signal new_target_selected(target: Targetable)

@export var cursor_targeting: CursorTargeting
@export var auto_targeting: AutoTargeting
@export var scan_targeting: ScanTargeting

@onready var signals := Globals.signal_bus

var current_target: Targetable:
    get = get_current_target,
    set = set_current_target


#region Target Selection
func cursor_target() -> void:
    #Globals.logger.debug("Attempting CURSOR target!")
    var starting_target: Targetable = null
    if is_instance_valid(current_target) and not current_target.is_queued_for_deletion():
        starting_target = current_target
    
    var cursor_detection_target := cursor_targeting.get_next_detected_target(starting_target)
    if is_instance_valid(cursor_detection_target) and cursor_detection_target != current_target:
        #Globals.logger.debug("CURSOR TARGET: updating current target!")
        current_target = cursor_detection_target


func next_target() -> void:
    #print("attempting NEXT auto target!")
    var starting_target: Targetable = null
    if is_instance_valid(current_target) and not current_target.is_queued_for_deletion():
        starting_target = current_target
    var next_auto_target := auto_targeting.get_next_detected_target(starting_target)
    if is_instance_valid(next_auto_target) and next_auto_target != current_target:
        #Globals.logger.debug("AUTO NEXT TARGET: updating current target!")
        current_target = next_auto_target


func previous_target() -> void:
    #Globals.logger.debug("attempting PREV auto target!")
    var starting_target: Targetable = null
    if is_instance_valid(current_target) and not current_target.is_queued_for_deletion():
        starting_target = current_target
    var prev_auto_target := auto_targeting.get_previous_detected_target(starting_target)
    if is_instance_valid(prev_auto_target) and prev_auto_target != current_target:
        #Globals.logger.debug("AUTO PREV TARGET: updating current target!")
        current_target = prev_auto_target


func target_self() -> void:
    var targetable := InstanceAPI.local_player.entity.targetable
    if targetable:
        current_target = targetable


func scan_target_right() -> void:
    #Globals.logger.debug("attempting RIGHT scan target!")
    var starting_target: Targetable = null
    if is_instance_valid(current_target) and not current_target.is_queued_for_deletion():
        starting_target = current_target
    var next_scan_target := scan_targeting.get_next_detected_target(starting_target)
    if is_instance_valid(next_scan_target) and next_scan_target != current_target:
        #Globals.logger.debug("SCAN NEXT TARGET: updating current target!")
        current_target = next_scan_target


func scan_target_left() -> void:
    #Globals.logger.debug("attempting LEFT scan target!")
    var starting_target: Targetable = null
    if is_instance_valid(current_target) and not current_target.is_queued_for_deletion():
        starting_target = current_target
    var prev_scan_target := scan_targeting.get_previous_detected_target(starting_target)
    if is_instance_valid(prev_scan_target) and prev_scan_target != current_target:
        #Globals.logger.debug("SCAN PREV TARGET: updating current target!")
        current_target = prev_scan_target
#endregion


#region Target Retrieval
func has_valid_target() -> bool:
    return is_instance_valid(current_target)


func get_current_target() -> Targetable:
    return current_target


func set_current_target(new_target: Targetable) -> void:
    if is_instance_valid(current_target):
        current_target.hide_indicator()
    
    current_target = new_target
    
    if is_instance_valid(current_target):
        #Globals.logger.debug("setting new current target to: ", new_target.get_parent().get_parent().name)
        current_target.show_indicator()
    
    # Always emit this for new targets AND for unselecting target (null)
    new_target_selected.emit(current_target)


func clear_current_target() -> void:
    current_target = null
#endregion


#region Godot Callbacks
func _ready() -> void:
    signals.cursor_target.connect(cursor_target)
    signals.next_target.connect(next_target)
    signals.previous_target.connect(previous_target)
    signals.target_self.connect(target_self)
    signals.scan_target_right.connect(scan_target_right)
    signals.scan_target_left.connect(scan_target_left)
    signals.cancel_target.connect(clear_current_target)
#endregion
