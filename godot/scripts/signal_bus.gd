class_name SignalBus extends Node

#region API
@warning_ignore("unused_signal")
signal api_status_passed()
@warning_ignore("unused_signal")
signal api_status_failed(http_code: int)

# Authentication
@warning_ignore("unused_signal")
signal login_success()
@warning_ignore("unused_signal")
signal login_failed(http_code: int)
@warning_ignore("unused_signal")
signal register_success(data: Dictionary)
@warning_ignore("unused_signal")
signal register_failed(http_code: int, error_message: String)
@warning_ignore("unused_signal")
signal logout_success()
@warning_ignore("unused_signal")
signal token_refresh_success()
@warning_ignore("unused_signal")
signal token_refresh_failed(http_code: int)
@warning_ignore("unused_signal")
signal user_info_received(user_data: Dictionary)

# Character Management
@warning_ignore("unused_signal")
signal character_created(character_data: Dictionary)
@warning_ignore("unused_signal")
signal character_create_failed(http_code: int, error_message: String)
@warning_ignore("unused_signal")
signal characters_received(characters: Array, total: int)
@warning_ignore("unused_signal")
signal characters_fetch_failed(http_code: int)
@warning_ignore("unused_signal")
signal character_received(character_data: Dictionary)
@warning_ignore("unused_signal")
signal character_fetch_failed(http_code: int)
@warning_ignore("unused_signal")
signal character_updated(character_data: Dictionary)
@warning_ignore("unused_signal")
signal character_update_failed(http_code: int)
@warning_ignore("unused_signal")
signal character_deleted()
@warning_ignore("unused_signal")
signal character_delete_failed(http_code: int)
@warning_ignore("unused_signal")
signal character_not_found()
@warning_ignore("unused_signal")
signal character_selected(character_data: Dictionary)
#endregion

#region Shard Connection
@warning_ignore("unused_signal")
signal connected_to_shard
@warning_ignore("unused_signal")
signal disconnected_from_shard
@warning_ignore("unused_signal")
signal shard_connection_failed
#endregion

#region Network (Legacy - keeping for compatibility)
@warning_ignore("unused_signal")
signal connection_closed
@warning_ignore("unused_signal")
signal got_packet(packet)
@warning_ignore("unused_signal")
signal got_client_id(msg)
@warning_ignore("unused_signal")
signal login(msg)
#endregion

#region Entity
@warning_ignore("unused_signal")
signal spawn_entity(entity: Entity)
@warning_ignore("unused_signal")
signal despawn_entity(entity: Entity)
@warning_ignore("unused_signal")
signal control_entity(entity: Entity)
#endregion

#region UI
@warning_ignore("unused_signal")
signal spawn_view(view: View)
@warning_ignore("unused_signal")
signal despawn_view(view: View)
#endregion

#region Logging
@warning_ignore("unused_signal")
signal log_new_message(message: String)
@warning_ignore("unused_signal")
signal log_new_debug(message: String)
@warning_ignore("unused_signal")
signal log_new_warning(message: String)
@warning_ignore("unused_signal")
signal log_new_error(message: String)
@warning_ignore("unused_signal")
signal log_new_success(message: String)
@warning_ignore("unused_signal")
signal log_new_announcment(message: String)
#endregion

#region World
@warning_ignore("unused_signal")
signal reload
@warning_ignore("unused_signal")
signal load_world
#endregion

#region Chat
@warning_ignore("unused_signal")
signal chat(sender_name: String, message: String)
#endregion

#region Input
@warning_ignore("unused_signal")
signal ui_accept 
@warning_ignore("unused_signal")
signal ui_cancel
@warning_ignore("unused_signal")
signal move(dir: Vector2)
@warning_ignore("unused_signal")
signal toggle_ui(state:bool)
#endregion
