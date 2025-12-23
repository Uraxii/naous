class_name NaousNet extends Node

const SERVER_ID := 1


func from_server() -> bool:
    return multiplayer.get_remote_sender_id() == SERVER_ID


func get_peer() -> int:
    return multiplayer.get_remote_sender_id()
