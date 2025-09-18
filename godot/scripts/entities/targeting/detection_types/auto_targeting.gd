class_name AutoTargeting extends TargetingDetection


## Targets closer to the player ("camera target") position have higher priority
func _target_sort(target_A: Targetable, target_B: Targetable) -> bool:
    var player_body: CharacterBody3D = get_camera_body()
    var target_A_distance_to_player := player_body.global_position.distance_to(target_A.entity.body.global_position)
    var target_B_distance_to_player := player_body.global_position.distance_to(target_B.entity.body.global_position)
    
    return target_A_distance_to_player < target_B_distance_to_player
