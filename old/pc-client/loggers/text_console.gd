# Global Console
class_name TextConsole extends Node

var history: Array[String] = []


func _ready() -> void:
    Global.sig_bus.log_new_message.connect(_on_log_message)
    Global.sig_bus.log_new_debug.connect(_on_log_debug)
    Global.sig_bus.log_new_warning.connect(_on_log_warning)
    Global.sig_bus.log_new_error.connect(_on_log_error)
    Global.sig_bus.log_new_announcment.connect(_on_log_announcement)


func _on_log_message(message: String) -> void:
    history.append(message)
    
    await get_tree().process_frame
    
    if len(Global.sig_bus.log_new_message.get_connections()) == 1 :
        Logger.info(message)


func _on_log_debug(message: String) -> void:
    history.append(message)
    
    await get_tree().process_frame
    
    if len(Global.sig_bus.log_new_debug.get_connections()) == 1:
        Logger.info(message)


func _on_log_warning(message: String) -> void:
    history.append(message)
    
    await get_tree().process_frame
    
    if len(Global.sig_bus.log_new_warning.get_connections()) == 1:
        Logger.warn(message)
    
        
func _on_log_error(message: String) -> void:
    history.append(message)
    
    await get_tree().process_frame
    
    if len(Global.sig_bus.log_new_error.get_connections()) == 1:
        Logger.warn(message)


func _on_log_announcement(message: String) -> void:
    history.append(message)
    
    await get_tree().process_frame
    
    if not len(Global.sig_bus.log_new_announcment.get_connections()) > 1:
        Logger.info(message)
