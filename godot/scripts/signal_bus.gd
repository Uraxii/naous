class_name SignalBus extends Node

#region HTTP Signals
signal logged_in
signal logged_out
#endregion

#region Web Socket Signals
signal connected_to_server
signal connection_closed

signal claim_token_received(packet)
signal deny_received(packet)
signal chat_message_received(packet)
signal server_message_received(packet)
#endregion

#region Instance API
signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)
signal server_disconnected
signal save_game
#endregion

#region Network (Legacy - keeping for compatibility)
signal got_packet(packet)
signal got_client_id(msg)
signal login(msg)
#endregion

#region Spell Casting
signal damage_entity(id: int, amount: float)
#endregion

#region Entity
signal spawn_entity(entity: Entity)
signal despawn_entity(entity: Entity)
signal control_entity(entity: Entity)
#endregion

#region UI
signal spawn_view(view: View)
signal despawn_view(view: View)
#endregion

#region Logging
signal log_new_message(message: String)
signal log_new_debug(message: String)
signal log_new_warning(message: String)
signal log_new_error(message: String)
signal log_new_success(message: String)
signal log_new_announcment(message: String)
#endregion

#region World
signal reload
signal load_world
#endregion

#region Chat
signal chat(sender_name: String, message: String)
#endregion

#region Input
signal ui_accept 
signal ui_cancel
signal ui_toggle(state:bool)

signal camera_zoom_in
signal camera_zoom_out
signal camera_move_start
signal camera_move_stop
signal camera_rotate(delta: Vector2)
signal character_rotate_start
signal character_rotate_stop

signal jump
signal interact
signal move(dir: Vector2)

#region Targeting
signal cursor_target
signal next_target
signal previous_target
signal scan_target_right
signal scan_target_left
signal cancel_target

signal action_0
signal action_1
signal action_2
signal action_3
signal action_4
#endregion

#region Interaction
signal entity_detected_interactable(entity: Entity, interactable: InteractableComponent)
signal entity_attempting_interaction(entity: Entity, interactable: InteractableComponent)
signal entity_started_interaction(entity: Entity, interactable: InteractableComponent)
signal entity_completed_interaction(entity: Entity, interactable: InteractableComponent)
signal entity_interaction_interrupted(entity: Entity, interactable: InteractableComponent)
signal entity_lost_interactable(entity: Entity, interactable: InteractableComponent)
#endregion

#region Aiming
signal target_entered_screen(target: Targetable)
signal target_exited_screen(target: Targetable)
#endregion
