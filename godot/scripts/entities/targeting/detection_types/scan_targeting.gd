## Scans strictly left and right for targets. Only considers their distance to the center of the screen
class_name ScanTargeting extends TargetingDetection


# TODO: Implement setting for respecting these directions. Should be able to just resort the "detectors" array
#enum DIRS {LEFT, RIGHT}

#@export var scan_direction: DIRS


## Gets the target closest to the center of the screen
func get_highest_priority_target() -> Targetable:
    var copied_targets: Array[Targetable]
    copied_targets.assign(prioritized_target_list)
    copied_targets.sort_custom(_sort_targets_by_distance_to_screen_center)
    return copied_targets.front()


## Default sort is to use distance to screen center (closer = higher priority)
func _target_sort(target_A: Targetable, target_B: Targetable) -> bool:
    return _sort_targets_by_screen_x(target_A, target_B)


## Sort targets based on their distance to the center of the screen
func _sort_targets_by_distance_to_screen_center(target_A: Targetable, target_B: Targetable) -> bool:
    var screen_center_x := _get_screen_center_x()
    var current_camera := get_camera()
    var target_A_screen_pos := current_camera.unproject_position(target_A.entity.global_position)
    var target_B_screen_pos := current_camera.unproject_position(target_B.entity.global_position)
    var target_A_distance_to_center := absf(target_A_screen_pos.x - screen_center_x)
    var target_B_distance_to_center := absf(target_B_screen_pos.x - screen_center_x)
    return target_A_distance_to_center < target_B_distance_to_center


## Sort targets based solely on their x position of the screen (left = high priority, right = low priority)
func _sort_targets_by_screen_x(target_A: Targetable, target_B: Targetable) -> bool:
    var current_camera := get_camera()
    var target_A_screen_pos := current_camera.unproject_position(target_A.entity.global_position)
    var target_B_screen_pos := current_camera.unproject_position(target_B.entity.global_position)
    return target_A_screen_pos.x < target_B_screen_pos.x


func _get_screen_center_x() -> float:
    var viewport := get_viewport()
    var viewport_rect := viewport.get_visible_rect()
    var viewport_width := viewport_rect.size.x
    var screen_center_x := viewport_width / 2
    return screen_center_x


#region Godot Callbacks
func _ready() -> void:
    super._ready()
#endregion
