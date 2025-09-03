## Defines camera-based collision that can detect and return Targetable objects
class_name TargetDetector extends Polygon2D

signal current_targets_updated(target_list: Array[Targetable])

@onready var targeting := Globals.targeting
@onready var camera := Globals.camera.camera

var _current_targets: Array[Targetable]:
    get = get_current_targets


#region Detecting Targets
func get_current_targets() -> Array[Targetable]:
    return _current_targets


func detect_targets() -> void:
    var previous_targets := []
    previous_targets.assign(_current_targets)
    var valid_targets := targeting.get_valid_targets()
    for possible_target: Targetable in valid_targets:
        var target_is_detected := _target_is_in_shape(possible_target, self)
        if target_is_detected:
            _add_current_target(possible_target)
        else:
            _remove_current_target(possible_target)
    
    if previous_targets != _current_targets:
        #print("updating detected shapes! - ", self.name)
        current_targets_updated.emit(_current_targets)


func _target_is_in_shape(possible_target: Targetable, screen_shape: Polygon2D) -> bool:
    var target_entity: Entity = possible_target.entity
    var target_visual_instances := target_entity.find_children("*", "VisualInstance3D")
    var first_visual_instance: VisualInstance3D = target_visual_instances[0] as VisualInstance3D
    var target_aabb := first_visual_instance.get_aabb()
    var transformed_aabb := target_aabb * first_visual_instance.global_transform
    var target_aabb_points := _generate_screen_points_of_aabb(transformed_aabb)
    
    var target_in_shape := false
    for aabb_point: Vector2 in target_aabb_points:
        if Geometry2D.is_point_in_polygon(aabb_point, screen_shape.polygon):
            target_in_shape = true
            break
    
    return target_in_shape


func _generate_screen_points_of_aabb(aabb: AABB) -> Array[Vector2]:
    var aabb_points_3D := [
        # "Front" face
        Vector3(aabb.position),
        Vector3(aabb.position) + Vector3(aabb.size.x, 0, 0),
        Vector3(aabb.position) + Vector3(0, aabb.size.y, 0),
        Vector3(aabb.position) + Vector3(aabb.size.x, aabb.size.y, 0),
        
        # "Back" face
        Vector3(aabb.end) - Vector3(aabb.size.x, aabb.size.y, 0),
        Vector3(aabb.end) - Vector3(0, aabb.size.y, 0),
        Vector3(aabb.end) - Vector3(aabb.size.x, 0, 0),
        Vector3(aabb.end),
    ]
    
    var aabb_points: Array[Vector2]
    for aabb_3d_point: Vector3 in aabb_points_3D:
        var new_point := camera.unproject_position(aabb_3d_point)
        aabb_points.push_back(new_point)
    return aabb_points


func _add_current_target(new_target: Targetable) -> void:
    if not _current_targets.has(new_target):
        _current_targets.push_back(new_target)


func _remove_current_target(lost_target: Targetable) -> void:
    if _current_targets.has(lost_target):
        _current_targets.erase(lost_target)
#endregion


#region Godot Callbacks
func _physics_process(_delta: float) -> void:
    detect_targets()


func _ready() -> void:
    visible = false # Hide the shape from the screen
#endregion
