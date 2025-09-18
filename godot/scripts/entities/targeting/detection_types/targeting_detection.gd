class_name TargetingDetection extends Node

## List of TargetDetector nodes to use for the detection logic. Order matters! First has highest priority, last has lowest priority. If this is left unset, the child TargetDetector nodes of this scene will be used to populate this value with nodes near the "top" of the tree given higher priority.
@export var detectors: Array[TargetDetector]
## When enabled, displays the detector shapes visually on the screen.
@export var enable_debug_view: bool = false:
    set = set_debug_mode_for_detectors

@onready var targeting := Globals.targeting

var camera: Camera3D:
    get = get_camera

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


#region Detector Target Handling
func update_prioritized_targets_for_detectors() -> void:
    #Globals.logger.debug("updating priority targets! - ", self.name)
    prioritized_target_list.clear()
    var currently_detected_targets := _get_currently_detected_targets()
    prioritized_target_list.assign(currently_detected_targets)
    _queued_for_target_updated = false


## Returns a prioritized list of currently detected targets. Can be overridden to extend the logic beyond just the Detectors
func _get_currently_detected_targets() -> Array[Targetable]:
    var detected_targets: Array[Targetable]
    for detector: TargetDetector in detectors:
        var detector_targets := detector.get_current_targets()
        if detector_targets.size() > 1:
            detector_targets = _prioritize_detector_targets(detector_targets)
        for target: Targetable in detector_targets:
            if not detected_targets.has(target):
                #Globals.logger.debug(("Frame %s: '%s' found target '%s' via detector '%s'" % [Engine.get_frames_drawn(), self.name, target.get_parent().get_parent().name, detector.name])
                detected_targets.push_back(target)
    return detected_targets
    

## Sorts a list of targets found by a single Detector (Detector order itself determines default priority order)
func _prioritize_detector_targets(targets: Array[Targetable]) -> Array[Targetable]:
    var prioritized_targets: Array[Targetable] = targets
    prioritized_targets.sort_custom(_target_sort)
    return prioritized_targets


func _attempt_queue_for_target_updates() -> void:
    if not _queued_for_target_updated:
        # We only want to execute this once per frame if multiple detectors signal on the same frame
        # This felt cleaner than testing every frame via '_process'
        _queued_for_target_updated = true
        update_prioritized_targets_for_detectors.call_deferred()
    

func _on_detector_targets_changed(_targets: Array[Targetable]) -> void:
    _attempt_queue_for_target_updates()


func _set_detectors_from_children() -> void:
    detectors.clear()
    
    var detector_children := find_children("*", "TargetDetector")
    if not detector_children.is_empty():
        for detector: TargetDetector in detector_children:
            # I can't find documentation stating that 'find_children' returns a determistic order of child nodes (such as in scene-tree order as see in the editor). Using the node's index to be 100% sure that the order is maintained.
            var detector_child_index := detector.get_index()
            detectors.insert(detector_child_index, detector)
#endregion


#region Camera
func get_camera() -> Camera3D:
    return Globals.camera.get_current_camera()


func get_camera_body() -> CharacterBody3D:
    return Globals.camera.target as CharacterBody3D
#endregion


#region Debugging
func set_debug_mode_for_detectors(enable_debug: bool) -> void:
    enable_debug_view = enable_debug
    if is_inside_tree():
        #Globals.logger.debug("%s setting debug view: %s" % [self.name, enable_debug])
        for detector: TargetDetector in detectors:
            detector.set_debug_mode(enable_debug)
#endregion


## Implementation should override this
@warning_ignore("unused_parameter")
func _target_sort(target_A: Targetable, target_B: Targetable) -> bool:
    push_warning("Using base implementation of target sort! Targets will remain unsorted. Did you mean to override this?")
    return true


#region Godot Callbacks
func _ready() -> void:
    # Fallback in case the user didn't set these manually
    if detectors.is_empty():
        _set_detectors_from_children()
    
    set_debug_mode_for_detectors(enable_debug_view)
    for detector: TargetDetector in detectors:
        detector.current_targets_updated.connect(_on_detector_targets_changed)
#endregion
