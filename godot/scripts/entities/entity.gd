class_name Entity extends Node3D

#region Variables
signal change_control(is_local: bool)

@export_category("Components")
@export var components: ComponentManager
@export var health:     HealthComponent
@export var speed:      StatComponent
@export var gravity:    StatComponent
@export var jump_force: StatComponent
@export var move:       ComponentMove
@export var body:       Node3D
@export var spellbook:  ComponentSpellbook
@export var inventory:  Node
@export_category("Runtime Values")
@export var id := -1

@onready var lg: Log = Globals.logger


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
    #lg.debug("Entity %s - Authority: %d, Local: %s" %
        #[name, get_multiplayer_authority(), is_local])

    change_control.emit(is_local)

    if is_local:
        signals.control_entity.emit(self)



#region Godot Callback Functions
func _enter_tree() -> void:
    if stored_authority != 1:
        transform_sync.set_multiplayer_authority(stored_authority)


func _ready() -> void:
    if not components: components = find_child("Components")
    if components:
        if not health:      health      = components.find("Health")
        if not speed:       speed       = components.find("Speed")
        if not gravity:     gravity     = components.find("Gravity")
        if not jump_force:  jump_force  = components.find("JumpForce")
        if not spellbook:   spellbook   = components.find("Spellbook")
        if not body:        body        = components.find("Body")
        if not move:        move        = components.find("Move")
        if not inventory:   inventory   = components.find("Inventory")
        
    for comp: Node in components.map.values():
        if comp.has_method("set_entity"):
            comp.set_entity(self)
    
    # This MUST be last!
    _check_local_authority()
#endregion
