class_name Targetable extends Node

const INDICATOR_SCENE: PackedScene = preload("uid://b74mdgvt321do")

@export var entity: Entity ## The owning Entity object that can be targeted

@onready var signals := Globals.signal_bus

var screen_notifier: TargetableScreenNotifier
var indicator: TargetingIndicator


func get_targeting_info() -> void:
    pass


func show_indicator() -> void:
    indicator.show()


func hide_indicator() -> void:
    indicator.hide()


func _setup_screen_notifier_for_target() -> void:
    # If there is already one, just rebuild it
    if is_instance_valid(screen_notifier):
        screen_notifier.queue_free()
    
    var new_screen_notifier := TargetableScreenNotifier.new()
    screen_notifier = new_screen_notifier
    screen_notifier.targetable = self
    entity.add_child(screen_notifier)


func _setup_target_indicator() -> void:
    # If there is already one, just rebuild it
    if is_instance_valid(indicator):
        indicator.queue_free()
    
    var new_indicator := INDICATOR_SCENE.instantiate()
    indicator = new_indicator
    entity.body.add_child(indicator)
    indicator.set_owning_entity(entity)


#region Godot Callbacks
func _ready() -> void:
    # Have to defer this since the parent of targetable may be setting up still
    _setup_screen_notifier_for_target.call_deferred()
    _setup_target_indicator.call_deferred()
    hide_indicator.call_deferred()
#endregion
