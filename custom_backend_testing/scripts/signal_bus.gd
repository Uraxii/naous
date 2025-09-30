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
