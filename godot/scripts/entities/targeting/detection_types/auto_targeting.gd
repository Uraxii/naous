class_name AutoTargeting extends TargetingDetection

@onready var camera_manager := Globals.camera


## Targets closer to the player ("camera target") position have higher priority
func _target_sort(target_A: Targetable, target_B: Targetable) -> bool:
    #var camera_target_pos := camera_manager.target.global_position
    #var camera_target_screen_pos := camera_manager.camera.unproject_position(camera_target_pos)
    #
    #var target_A_screen_pos := camera_manager.camera.unproject_position(target_A.entity.global_position)
    #var target_B_screen_pos := camera_manager.camera.unproject_position(target_B.entity.global_position)
    var target_A_distance_to_player := camera_manager.target.body.global_position.distance_to(target_A.entity.body.global_position)
    var target_B_distance_to_player := camera_manager.target.body.global_position.distance_to(target_B.entity.body.global_position)
    #var target_B_distance_to_player := target_B_screen_pos.distance_to(camera_target_screen_pos)
    
    return target_A_distance_to_player < target_B_distance_to_player
