class_name CursorTargeting extends TargetingDetection

@export_flags_3d_physics var raycast_collision_mask: int

const RAYCAST_LENGTH := 500.0

@onready var camera_manager := Globals.camera
@onready var camera := Globals.camera.camera

var cursor_detector: TargetDetector

var _raycast_targets: Array[Targetable]


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


func update_raycast_targets() -> void:
    _raycast_targets.clear()
    
    # TODO: Currently just detecting 1 target per raycast. If we expand this to look for multiple (ie. the raycast "pierces" the first object to find more), we just need to update this to handle a list of objects instead of just one.
    var mouse_position := get_viewport().get_mouse_position()
    var current_targetable := find_targetable_at_cursor_position(mouse_position)
    if is_instance_valid(current_targetable):
        # TODO: Add prioritization logic to list of raycast targets
        _raycast_targets.push_back(current_targetable)
        update_prioritized_targets_for_detectors()


func find_targetable_at_cursor_position(cursor_pos: Vector2) -> Targetable:
    var player_body: CharacterBody3D = camera_manager.target
    if not is_instance_valid(player_body):
        return null
    
    var found_targetable: Targetable = null
    
    # Prep our raycast details
    var world_space_3d := camera.get_world_3d().direct_space_state
    var ray_from := camera.project_ray_origin(cursor_pos)
    var ray_to := camera.project_ray_normal(cursor_pos) * RAYCAST_LENGTH
    var ray_collision_mask := raycast_collision_mask
    # TODO: Refactor if we wnat to start looking for multiple objects in the future. We'd loop around some condition and keep casting while adding each found object to this 'exluded' list to prevent it from beign detected on the next cast.
    var excluded_objects: Array[RID]
    excluded_objects.push_back(player_body.get_rid())
    
    # Assemble our raycast query
    var ray_query_params := PhysicsRayQueryParameters3D.create(ray_from, ray_to, ray_collision_mask, excluded_objects)
    ray_query_params.collide_with_areas = true
    ray_query_params.hit_from_inside = true
    
    # Cast the ray and check for collisions
    var intersection_result := world_space_3d.intersect_ray(ray_query_params)
    if not intersection_result.is_empty():
        var entity_body_found: CollisionObject3D = intersection_result.get("collider")
        # If the cast failed, we'll get a null object
        if entity_body_found != null:
            var targetable_entity: Targetable
            # Find a valid Targetable Entity that contains the body we found
            var valid_targets := targeting.get_valid_targets()
            for valid_target: Targetable in valid_targets:
                var target_entity := valid_target.entity
                if target_entity.body == entity_body_found:
                    targetable_entity = target_entity.components.find("Targetable")
                    if targetable_entity != null:
                        #print("Cursor raycast found Target: ", targetable_entity.get_parent().get_parent().name)
                        found_targetable = targetable_entity
    
    return found_targetable


func _get_currently_detected_targets() -> Array[Targetable]:
    var detector_targets := super._get_currently_detected_targets()
    
    for raycast_target: Targetable in _raycast_targets:
        # Remove the object from the detectors list if the raycast already found it
        if detector_targets.has(raycast_target):
            detector_targets.erase(raycast_target)
        
        detector_targets.push_front(raycast_target)
    
    return detector_targets
    

#region Godot Callbacks
func _process(_delta: float) -> void:
    var cursor_position: Vector2 = get_viewport().get_mouse_position()
    sync_detectors_to_cursor(cursor_position)


func _physics_process(_delta: float) -> void:
    update_raycast_targets()
#endregion
