class_name View extends Control

@export var should_log := false

@onready var signals := Globals.signal_bus
@onready var router  := Globals.msg_router
@onready var input   := Globals.input
@onready var views   := Globals.views
@onready var save    := Globals.save
@warning_ignore("shadowed_global_identifier")
@onready var log     := Globals.logger


func initalize() -> void:
    visibility_changed.connect(_on_visibility_change)


func despawn():
    signals.despawn_view.emit(self)
    queue_free.call_deferred()


func _on_visibility_change() -> void:
    if should_log:
        print_debug(self, " visible:", is_visible_in_tree())
