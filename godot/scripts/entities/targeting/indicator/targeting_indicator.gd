class_name TargetingIndicator extends Node3D

const RADIUS_BUFFER := 0.3

@onready var circle: MeshInstance3D = %Circle
@onready var pointer: MeshInstance3D = %Pointer

var entity: Entity:
    set = set_owning_entity


func set_owning_entity(owning_entity: Entity) -> void:
    entity = owning_entity
    adjust_ground_indicator_for_entity(entity)
    adjust_pointer_indicator_for_entity(entity)


func adjust_ground_indicator_for_entity(target_entity: Entity) -> void:
    var target_visual_instances := target_entity.find_children("*", "VisualInstance3D")
    var first_visual_instance: VisualInstance3D = target_visual_instances[0] as VisualInstance3D
    var target_aabb := first_visual_instance.get_aabb()
    var transformed_aabb := target_aabb * first_visual_instance.global_transform
    var circle_radius := sqrt(pow(transformed_aabb.size.x, 2) + pow(transformed_aabb.size.z, 2)) / 2
    var torus_mesh: TorusMesh = circle.mesh as TorusMesh
    var concentric_radius_diff := torus_mesh.outer_radius - torus_mesh.inner_radius
    torus_mesh.inner_radius = circle_radius + RADIUS_BUFFER
    torus_mesh.outer_radius = torus_mesh.inner_radius + concentric_radius_diff
    print("updated inner radius for mesh %s = %s" % [entity.name, circle_radius])


func adjust_pointer_indicator_for_entity(target_entity: Entity) -> void:
    pass


func set_material_color(new_color: Color) -> void:
    var circle_mesh := circle.mesh.surface_get_material(0)
    circle_mesh.color = new_color
    var pointer_mesh := pointer.mesh.surface_get_material(0)
    pointer_mesh.color = new_color


#region Godot Callbacks
func _ready() -> void:
    if is_instance_valid(entity):
        adjust_ground_indicator_for_entity(entity)
        adjust_pointer_indicator_for_entity(entity)
#endregion
