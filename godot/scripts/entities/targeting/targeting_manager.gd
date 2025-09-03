class_name TargetingManager extends Node

signal player_targeted(player: Entity, target: )

const INDICATOR: PackedScene = preload("uid://b74mdgvt321do") # targeting_indicator.tscn

@onready var signals := Globals.signal_bus

var valid_targets: Array[Targetable]:
    get = get_valid_targets


func get_valid_targets() -> Array[Targetable]:
    return valid_targets

func add_valid_target(new_target: Targetable) -> void:
    if not valid_targets.has(new_target):
        valid_targets.push_back(new_target)


func remove_valid_target(lost_target: Targetable) -> void:
    if valid_targets.has(lost_target):
        valid_targets.erase(lost_target)


func _target_entered_screen(target: Targetable) -> void:
    add_valid_target(target)


func _target_exited_screen(target: Targetable) -> void:
    remove_valid_target(target)


#region Godot Callbacks
func _ready() -> void:
    signals.target_entered_screen.connect(_target_entered_screen)
    signals.target_exited_screen.connect(_target_exited_screen)
#endregion
