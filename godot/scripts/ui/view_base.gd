class_name View extends Control

var signals: SignalBus:
    get: return Globals.signal_bus

var input: InputManager:
    get: return Globals.input
 
var views: ViewManager:
    get: return Globals.views

@warning_ignore("shadowed_global_identifier")
var log: Log:
    get: return Globals.logger


func initalize() -> void:
    visibility_changed.connect(_on_visibility_change)    
    

func despawn():
    signals.despawn_view.emit(self)
    queue_free.call_deferred()


func _on_visibility_change() -> void:
    #print_debug(self, " visible:", is_visible_in_tree())
    pass
