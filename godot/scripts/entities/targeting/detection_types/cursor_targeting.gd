class_name CursorTargeting extends TargetingDetection

@onready var camera := Globals.camera.camera
var cursor_detector: TargetDetector


func sync_detectors_to_cursor(cursor_pos: Vector2) -> void:
    for detector: TargetDetector in detectors:
        detector.global_position = cursor_pos


## Targets closer to the cursor position have higher priority
func _target_sort(target_A: Targetable, target_B: Targetable) -> bool:
    var cursor_position: Vector2 = get_viewport().get_mouse_position()
    
    var target_A_screen_pos := camera.unproject_position(target_A.entity.global_position)
    var target_B_screen_pos := camera.unproject_position(target_B.entity.global_position)
    var target_A_distance_to_cursor := target_A_screen_pos.distance_to(cursor_position)
    var target_B_distance_to_cursor := target_B_screen_pos.distance_to(cursor_position)
    return target_A_distance_to_cursor < target_B_distance_to_cursor


#region Godot Callbacks
func _process(_delta: float) -> void:
    var cursor_position: Vector2 = get_viewport().get_mouse_position()
    sync_detectors_to_cursor(cursor_position)
#endregion
