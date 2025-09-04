class_name Entity extends Node3D

#region Variables
signal change_control(is_local: bool)

@export var components: ComponentManager
@export_category("Runtime Values")
@export var id := -1


var entities: EntityManager:
    get: return Globals.entities

var signals: SignalBus:
    get: return Globals.signal_bus

var _transform_sync: MultiplayerSynchronizer
# The synchronizer is a lazy-backed property to fix timing issues with spawning.
var transform_sync: MultiplayerSynchronizer:
    get:
        if not _transform_sync:
            _transform_sync = find_child("TransformSynchronizer", true, false)
        return _transform_sync

var stored_authority := 1    
#endregion


@rpc("call_local")
func die() -> void:
    if not multiplayer.is_server():
        return
        
    signals.log_new_debug.emit("Entity %d died." % id)
    entities.despawn(id)


func _check_local_authority() -> void:
    var is_local = transform_sync.is_multiplayer_authority()
    signals.log_new_debug.emit(
        "Entity %s - Authority: %d, Local: %s" %
            [name, get_multiplayer_authority(), is_local])

    if is_local:
        signals.control_entity.emit(self)

    change_control.emit(is_local)


#region Godot Callback Functions
func _enter_tree() -> void:
    if stored_authority != 1:
        transform_sync.set_multiplayer_authority(stored_authority)


func _ready() -> void:
    _check_local_authority()
    
    if not components:
        components = find_child("Components")
#endregion
