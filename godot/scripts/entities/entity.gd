class_name Entity extends Node3D

enum EntityType {
    BASE,
    PLAYER,
    NPC,
    PROJECTILE,
}

signal change_control(is_local: bool)

var type: EntityType:
    get = get_type

func get_type() -> EntityType:
    push_warning("get_type is unimplemented.")
    return EntityType.BASE


@export var data := EntityData.new()

@export_category("Components")
@export var components:     ComponentManager
@export var anim:           ComponentAnimator
@export var stats:          ComponentStatManager
@export var health:         ComponentHealth
@export var speed:          ComponentStat
@export var gravity:        ComponentStat
@export var jump_force:     ComponentStat
@export var move:           ComponentMove
@export var body:           Node3D
@export var spellbook:      ComponentSpellbook
@export var inventory:      InventoryComponent
@export var interaction:    InteractionComponent
@export var targetable:     Targetable
@export var targeting:      TargetingSystem
@export_category("Runtime Values")
@export var id := 0
@export var target_id := 0:
    set = set_target_id

@onready var logger     := Globals.logger
@onready var entities   := Globals.entities
@onready var signals    := Globals.signal_bus

var display_name := "{ NAME }"

var target: Entity:
    get: return entities.find(target_id)

var is_local_owner: bool:
    get: return transform_sync.is_multiplayer_authority()

var _transform_sync: MultiplayerSynchronizer
# The synchronizer is a lazy-backed property to fix timing issues with spawning.
# If somone has a better solution, feel free to implement it.
var transform_sync: MultiplayerSynchronizer:
    get:
        if not _transform_sync:
            _transform_sync = find_child("LocalControlSynchronizer", true, false)
        return _transform_sync

var stored_authority := Globals.SERVER_ID


@rpc("call_local")
func die() -> void:
    if not multiplayer.is_server():
        return

    signals.log_new_debug.emit("Entity %d died." % id)
    entities.despawn(id)


func set_target_id(new_target_id: int) -> void:
    #Globals.logger.debug(
        #"Entity (%s, %s) setting new target id: %s" %
        #[self.name, self.get_instance_id(), new_target_id]
    #)
    target_id = new_target_id


func _check_local_authority() -> void:
    var is_local = transform_sync.is_multiplayer_authority()
    #lg.debug("Entity %s - Authority: %d, Local: %s" %
        #[name, get_multiplayer_authority(), is_local])

    change_control.emit(is_local)

    # TODO: Add "and not multiplayer.is_server()" check here in the future
    # Currently this appears to always be 'true' by default
    if is_local:
        signals.control_entity.emit(self)
        InstanceAPI.local_player.entity = self
        logger.debug("I am %s playing as %s" % [name, display_name])


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
    var instance_children := find_children("*", "VisualInstance3D")
    var visual_instances: Array[VisualInstance3D] = []
    visual_instances.assign(instance_children)
    return visual_instances


func _get_local_aabb_from_instances(visual_instances: Array[VisualInstance3D]) -> AABB:
    var final_aabb := AABB()

    for visual_instance: VisualInstance3D in visual_instances:
        var instance_aabb := visual_instance.get_aabb()
        if not final_aabb.has_volume():
            final_aabb = instance_aabb
        else:
            final_aabb.merge(instance_aabb)

    return final_aabb


func _get_world_transformed_aabb_from_instances(visual_instances: Array[VisualInstance3D]) -> AABB:
    var final_transformed_aabb := AABB()

    for visual_instance: VisualInstance3D in visual_instances:
        var instance_aabb := visual_instance.get_aabb()
        # MATRIX MATH ORDER MATTERS!
        # For global-space transforms, multiply the global transform BY the local transform (seen here)
        # This converts the local-space AABB transform (which doesn't contain things like scale or rotation) to its transform in global space.
        var world_instance_aabb := visual_instance.global_transform * instance_aabb
        if final_transformed_aabb.position == Vector3.ZERO and final_transformed_aabb.size == Vector3.ZERO:
            final_transformed_aabb = world_instance_aabb
        else:
            final_transformed_aabb.merge(world_instance_aabb)

    return final_transformed_aabb
#endregion


#region Components
func setup_components() -> void:
    if not components:
        components = find_child(ComponentManager.ID)

        if not components:
            push_warning(
                "Unable find component manger on %s. Ensure this node exists and its name is %s" % [
                    get_path(), ComponentManager.ID])
            return

    if not stats:
        stats = components.find(ComponentStatManager.ID)
    if not health:
        health = components.find(ComponentStat.HEALTH_ID)
    if not speed: 
        speed = components.find(ComponentStat.SPEED_ID)
    if not gravity:
        gravity = components.find(ComponentStat.GRAVITY_ID)
    if not jump_force: 
        jump_force = components.find(ComponentStat.JUMP_FORCE_ID)
    if not spellbook: 
        spellbook = components.find("Spellbook")
    if not body:
        body = components.find("Body")
    if not move:
        move = components.find("Move")
    if not inventory: 
        inventory = components.find("Inventory")
    if not interaction: 
        interaction = components.find("Interaction")
    if not targetable: 
        targetable = components.find("Targetable")
    if not targeting: 
        targeting = components.find("TargetingSystem")
    if not anim:
        anim = components.find("Animator")

    if is_instance_valid(targeting):
        targeting.new_target_selected.connect(_new_target_selected)


func _new_target_selected(new_target: Targetable) -> void:
    if is_instance_valid(new_target):
        set_target_id(new_target.entity.id)
    else:
        set_target_id(0) # Some default, adjust if needed
#endregion


#region Godot Callback Functions
func _enter_tree() -> void:
    if stored_authority != 1:
        transform_sync.set_multiplayer_authority(stored_authority)


func _ready() -> void:
    setup_components()

    for comp: Node in components.map.values():
        if comp.has_method("set_entity"):
            comp.set_entity(self)

    # This MUST be last!
    _check_local_authority()
#endregion
