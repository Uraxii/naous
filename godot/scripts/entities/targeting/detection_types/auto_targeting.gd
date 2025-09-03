class_name AutoTargeting extends TargetingDetection

@onready var camera_target := Globals.camera.target
@onready var camera := Globals.camera.camera


## Targets closer to the cursor position have higher priority
func _target_sort(target_A: Targetable, target_B: Targetable) -> bool:    
    var camera_target_screen_pos := camera.unproject_position(camera_target.global_position)
    
    var target_A_screen_pos := camera.unproject_position(target_A.entity.global_position)
    var target_B_screen_pos := camera.unproject_position(target_B.entity.global_position)
    var target_A_distance_to_cursor := target_A_screen_pos.distance_to(camera_target_screen_pos)
    var target_B_distance_to_cursor := target_B_screen_pos.distance_to(camera_target_screen_pos)
    
    return target_A_distance_to_cursor < target_B_distance_to_cursor
