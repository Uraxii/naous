class_name SignalBus extends Node

signal save_game

#region Instance API
signal connected_to_server()
signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)
signal server_disconnected
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

#region Input
signal ui_accept 
signal ui_cancel
signal ui_toggle(state:bool)
signal open_inventory
signal toggle_chat_input
signal allow_character_control(allow: bool)

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
#endregion Input

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

#region Character Select
signal selected_character(character_data: Dictionary)
#endregion

#region Network Messages
#endregion

#region Network Messages
signal test_msg(msg: MsgSpawnEntity)
signal chat_msg(msg: MsgChat)
signal spawn_entity_msg(msg: MsgSpawnEntity)
#endregion
