## Defines camera-based collision that can detect and return Targetable objects
class_name TargetDetector extends Polygon2D

signal current_targets_updated(target_list: Array[Targetable])

@export var debug_mode: bool = false:
    set = set_debug_mode

@onready var targeting := Globals.targeting
@onready var camera := Globals.camera.camera

var _current_targets: Array[Targetable]:
    get = get_current_targets


#region Detecting Targets
func get_polygon_shape() -> Polygon2D:
    return self


func get_current_targets() -> Array[Targetable]:
    return _current_targets


func detect_targets() -> void:
    var previous_targets := []
    previous_targets.assign(_current_targets)
    var valid_targets := targeting.get_valid_targets()
    for possible_target: Targetable in valid_targets:
        var target_is_detected := _target_is_in_shape(possible_target, get_polygon_shape())
        if target_is_detected:
            _add_current_target(possible_target)
        else:
            _remove_current_target(possible_target)
    
    if previous_targets != _current_targets:
        #print("updating detected shapes! - ", self.name)
        current_targets_updated.emit(_current_targets)


func _target_is_in_shape(possible_target: Targetable, screen_shape: Polygon2D) -> bool:
    var target_entity: Entity = possible_target.entity
    var entity_world_aabb := target_entity.get_world_aabb()
    var target_aabb_points := _generate_screen_points_of_aabb(entity_world_aabb)
    # MATRIX MATH ORDER MATTERS! Converting the shape polygon vertices to global screen space
    var screen_polygon := screen_shape.global_transform * screen_shape.polygon
    var target_in_shape := false
    for aabb_point: Vector2 in target_aabb_points:
        if Geometry2D.is_point_in_polygon(aabb_point, screen_polygon):
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
        #print("adding a target to: - ", self.name)
        _current_targets.push_back(new_target)


func _remove_current_target(lost_target: Targetable) -> void:
    if _current_targets.has(lost_target):
        #print("removing a target from: - ", self.name)
        _current_targets.erase(lost_target)


func _adjust_shape_to_screen() -> void:
    var project_window_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
    var project_window_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
    var current_viewport_rect := get_viewport_rect()
    var new_polygon_scale := Vector2(current_viewport_rect.size.x / project_window_width, current_viewport_rect.size.y / project_window_height)
    self.scale = new_polygon_scale
#endregion


#region Debugging
func set_debug_mode(enable_debug: bool) -> void:
    debug_mode = enable_debug
    visible = enable_debug
#endregion


#region Godot Callbacks
func _physics_process(_delta: float) -> void:
    detect_targets()


func _ready() -> void:
    get_viewport().size_changed.connect(_adjust_shape_to_screen)
#endregion
