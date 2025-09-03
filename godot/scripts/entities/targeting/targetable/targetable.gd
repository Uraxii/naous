class_name Targetable extends Node

@export var entity: Entity ## The owning Entity object that can be targeted

@onready var signals := Globals.signal_bus

var screen_notifier: TargetableScreenNotifier


func get_targeting_info() -> void:
    pass


func _setup_screen_notifier_for_target() -> void:
    # If there is already one, just rebuild it
    if is_instance_valid(screen_notifier):
        screen_notifier.queue_free()
    
    var new_screen_notifier := TargetableScreenNotifier.new()
    screen_notifier = new_screen_notifier
    screen_notifier.targetable = self
    entity.add_child(screen_notifier)


#region Godot Callbacks
func _ready() -> void:
    # Have to defer this since the parent of targetable may be setting up still
    _setup_screen_notifier_for_target.call_deferred()

#endregion
