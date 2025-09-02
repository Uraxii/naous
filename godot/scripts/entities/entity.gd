class_name Entity extends Node3D

#region Variables
signal change_control(is_local: bool)

const INVALID_ID: int = -1

# @export var data := EntityData.new()
@export var body: CharacterBody3D
@export var components: ComponentManager
@export var projectile_spawner: Node3D
@export_category("Runtime Values")
@export var id := INVALID_ID
@export var stored_authority := 1

var entities: EntityManager:
    get: return Globals.entities

var signals: SignalBus:
    get: return Globals.signal_bus
#endregion


func die() -> void:
    signals.log_new_debug.emit("Entity %d died." % id)
    entities.despawn(id)


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


#region Godot Callback Functions
func _enter_tree() -> void:
    if stored_authority != 1:
        set_multiplayer_authority(stored_authority)


func _ready() -> void:
    _check_local_authority()

#end_region
