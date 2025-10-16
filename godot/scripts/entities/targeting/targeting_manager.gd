class_name TargetingManager extends Node

#signal player_targeted(player: Entity, target: Entity)

const INDICATOR: PackedScene = preload("uid://b74mdgvt321do") # targeting_indicator.tscn

@onready var signals := Globals.signal_bus

var valid_targets: Array[Targetable]:
    get = get_valid_targets

var active_targeting_system: TargetingSystem


#region Targeting System Management
# This Manager will maintain an "active" TargetingSystem in order to determine what targeting rules and data is currently being used. This allows the Manager to be driven by any arbitrary TargetingSystem, allowing us to switch between any number of them at run-time.
# TargetingSystems are largely driven by the camera, so you could have multiple active cameras in the scene, each following their own Entity and its corresponding TargetingSystem. Alternatively, you can the TargetingSystem directly to some arbitrary Node and just rely on the current Viewport camera.

func get_current_target() -> Targetable:
    var current_target: Targetable = null
    if active_targeting_system != null:
        current_target = active_targeting_system.get_current_target()
    else:
        Globals.logger.error("Unable to retrieve current target! TargetingManager does not have an active targeting system!")
    return current_target


func set_current_target(new_target: Targetable) -> void:
    if active_targeting_system != null:
        active_targeting_system.set_current_target(new_target)
    else:
        Globals.logger.error("Unable to set current target! TargetingManager does not have an active targeting system!")


func clear_current_target() -> void:
    if active_targeting_system != null:
        active_targeting_system.clear_current_target()
    else:
        Globals.logger.error("Unable to clear current target! TargetingManager does not have an active targeting system!")


func register_active_targeting_system(new_targeting_system: TargetingSystem) -> void:
    Globals.logger.debug(
            "TargetingManager switching active TargetingSystem to '%s' with id '%s'" %
            [new_targeting_system.name, new_targeting_system.get_instance_id()]
        )
    active_targeting_system = new_targeting_system


func get_current_targeting_owner() -> Entity:
    if is_instance_valid(Globals.camera.target) and Globals.camera.target is ComponentCharacterBody:
        return (Globals.camera.target as ComponentCharacterBody).entity
    return null
#endregion


#region Valid Target Management
func get_valid_targets() -> Array[Targetable]:
    return valid_targets


func add_valid_target(new_target: Targetable) -> void:
    var current_targeting_owner := get_current_targeting_owner()
    if not valid_targets.has(new_target) and new_target.entity != current_targeting_owner:
        #Globals.logger.debug("Adding valid target: ", new_target.entity.name)
        valid_targets.push_back(new_target)


func remove_valid_target(lost_target: Targetable) -> void:
    if valid_targets.has(lost_target):
        valid_targets.erase(lost_target)


func _target_entered_screen(target: Targetable) -> void:
    add_valid_target(target)


func _target_exited_screen(target: Targetable) -> void:
    remove_valid_target(target)
#endregion


#region Godot Callbacks
func _ready() -> void:
    signals.control_entity.connect(_control_entity_changed)
    signals.target_entered_screen.connect(_target_entered_screen)
    signals.target_exited_screen.connect(_target_exited_screen)


func _control_entity_changed(new_controlling_entity: Entity) -> void:
    if new_controlling_entity.targeting != null:
        register_active_targeting_system(new_controlling_entity.targeting)
    else:
        Globals.logger.error("New controlling entity does not have a TargetingSystem!")
#endregion
