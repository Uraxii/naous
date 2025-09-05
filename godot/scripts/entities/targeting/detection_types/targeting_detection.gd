class_name TargetingDetection extends Node

## List of TargetDetector nodes to use for the detection logic. Order matters! First has highest priority, last has lowest priority.
@export var detectors: Array[TargetDetector]

var prioritized_target_list: Array[Targetable]

var _queued_for_target_updated := false


func get_next_detected_target(current_target: Targetable = null) -> Targetable:
    var next_target: Targetable = null # We'll return 'null' if no next target is found
    if current_target == null:
        next_target = get_highest_priority_target()
    else:
        next_target = get_next_target_by_lower_priority(current_target)
    
    return next_target


# TODO: Needs better naming? Naming on this isn't great... But it makes sense from a player perspective
func get_previous_detected_target(current_target: Targetable = null) -> Targetable:
    var prev_target: Targetable = null # We'll return 'null' if no previous target is found
    if current_target == null:
        prev_target = get_highest_priority_target()
    else:
        prev_target = get_next_target_by_higher_priority(current_target)
    
    return prev_target


func get_highest_priority_target() -> Targetable:
    var highest_priority_target: Targetable = null
    if not prioritized_target_list.is_empty():
        highest_priority_target = prioritized_target_list.front()
    return highest_priority_target


func get_next_target_by_lower_priority(target: Targetable) -> Targetable:
    var curr_target_index := prioritized_target_list.find(target)
    var next_lower_priority_target: Targetable = null
    
    if curr_target_index == -1:
        next_lower_priority_target = get_highest_priority_target()
        
    else:
        # Get the next target, loop back to beginning of list if we are at the end
        var next_target_index := (curr_target_index + 1) % prioritized_target_list.size()
        
        next_lower_priority_target = prioritized_target_list[next_target_index]
    
    return next_lower_priority_target


func get_next_target_by_higher_priority(target: Targetable) -> Targetable:
    var curr_target_index := prioritized_target_list.find(target)
    var next_higher_priority_target: Targetable = null
    
    if curr_target_index == -1:
        next_higher_priority_target = get_highest_priority_target()
    else:
        # Get the previous target, loop to end of list if we are at the beginning
        var next_target_index := curr_target_index - 1
        if next_target_index < 0:
            next_target_index = prioritized_target_list.size() - 1
        
        next_higher_priority_target = prioritized_target_list[next_target_index]
    
    return next_higher_priority_target


func update_prioritized_targets_for_detectors() -> void:
    #print("updating priority targets! - ", self.name)
    prioritized_target_list.clear()
    for detector: TargetDetector in detectors:
        var detector_targets := detector.get_current_targets()
        if detector_targets.size() > 1:
            detector_targets = _prioritize_detector_targets(detector_targets)
        for target: Targetable in detector_targets:
            if not prioritized_target_list.has(target):
                if self.name == "CursorTargeting":
                    print("Frame %s: '%s' found target '%s' via detector '%s'" % [Engine.get_frames_drawn(), self.name, target.get_parent().get_parent().name, detector.name])
                prioritized_target_list.push_back(target)
    _queued_for_target_updated = false


## Sorts a list of targets found by a single Detector (Detector order itself determines default priority order)
func _prioritize_detector_targets(targets: Array[Targetable]) -> Array[Targetable]:
    var prioritized_targets: Array[Targetable] = targets
    prioritized_targets.sort_custom(_target_sort)
    return prioritized_targets


func _on_detector_targets_changed(_targets: Array[Targetable]) -> void:
    if not _queued_for_target_updated:
        # We only want to execute this once per frame if multiple detectors signal on the same frame
        # This felt cleaner than testing every frame via '_process'
        _queued_for_target_updated = true
        update_prioritized_targets_for_detectors()


## Implementation should override this
@warning_ignore("unused_parameter")
func _target_sort(target_A: Targetable, target_B: Targetable) -> bool:
    push_warning("Using base implementation of target sort! Targets will remain unsorted. Did you mean to override this?")
    return true


#region Godot Callbacks
func _ready() -> void:
    for detector: TargetDetector in detectors:
        detector.current_targets_updated.connect(_on_detector_targets_changed)
#endregion
