class_name View extends Control

@onready var signals := Globals.signal_bus
@onready var session := Globals.session
@onready var http := Globals.http
@onready var ws := Globals.websocket
@onready var input := Globals.input
@onready var views := Globals.views
@warning_ignore("shadowed_global_identifier")
@onready var log := Globals.logger


func initalize() -> void:
	visibility_changed.connect(_on_visibility_change)    


func despawn():
	signals.despawn_view.emit(self)
	queue_free.call_deferred()


func _on_visibility_change() -> void:
	#print_debug(self, " visible:", is_visible_in_tree())
	pass
