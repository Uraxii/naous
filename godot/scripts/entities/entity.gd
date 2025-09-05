class_name Entity extends Node3D

#region Variables
signal change_control(is_local: bool)

const INVALID_ID: int = -1

# @export var data := EntityData.new()
@export var body: CharacterBody3D
@export var components: ComponentManager
@export_category("Runtime Values")
@export var id := INVALID_ID
@export var stored_authority := 1
@onready var entities := Globals.entities
@onready var projectile_spawner: Node3D = %ProjectileSpawner

var signals: SignalBus:
    get: return Globals.signal_bus
#endregion


func get_component(type: GDScript) -> Node:
    return components.get_component(type)


func _check_local_authority() -> void:
    var is_local = is_multiplayer_authority()
    signals.log_new_debug.emit(
        "Entity %s - Authority: %d, Local: %s" %
            [name, get_multiplayer_authority(), is_local])

    if is_local:
        signals.control_entity.emit(self)

    change_control.emit(is_local)

#region AABB Helpers
func get_local_aabb() -> AABB:
    var visual_instances := _get_visual_instances()
    var local_transformed_aabb := _get_local_aabb_from_instances(visual_instances)
    return local_transformed_aabb


func get_world_aabb() -> AABB:
    # FIXME: Account for scaling of nodes (need to pass this to Entity)
    var visual_instances := _get_visual_instances()
    var world_transformed_aabb := _get_world_transformed_aabb_from_instances(visual_instances)
    return world_transformed_aabb


func _get_visual_instances() -> Array[VisualInstance3D]:
    var visual_instances: Array[VisualInstance3D] = []
    var instance_children := find_children("*", "VisualInstance3D")
    visual_instances.assign(instance_children)
    return visual_instances


func _get_local_aabb_from_instances(visual_instances: Array[VisualInstance3D]) -> AABB:
    var final_aabb := AABB()
    
    for visual_instance: VisualInstance3D in visual_instances:
        var instance_aabb := visual_instance.get_aabb()
        final_aabb.merge(instance_aabb)
    
    return final_aabb


func _get_world_transformed_aabb_from_instances(visual_instances: Array[VisualInstance3D]) -> AABB:
    var final_transformed_aabb := AABB()
    
    for visual_instance: VisualInstance3D in visual_instances:
        var instance_aabb := visual_instance.get_aabb()
        var world_instance_aabb := visual_instance.global_transform * instance_aabb
        if final_transformed_aabb.position == Vector3.ZERO and final_transformed_aabb.size == Vector3.ZERO:
            final_transformed_aabb = world_instance_aabb
        else:
            final_transformed_aabb.merge(world_instance_aabb)
    
    return final_transformed_aabb


#endregion


#region Godot Callback Functions
func _enter_tree() -> void:
    if stored_authority != 1:
        set_multiplayer_authority(stored_authority)


func _ready() -> void:
    entities.spawn(self)
    _check_local_authority()


func _exit_tree() -> void:
    entities.despawn(self)
#endr_egion
