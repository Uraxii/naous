class_name Database extends Node

## Peer ID: PlayerData
var player_data: Dictionary[int, ComponentData]


func get_all_player_data() -> Array[ComponentData]:
    return player_data.values()


func get_player_data(user_id: int) -> ComponentData:
    return player_data.get(user_id)


func set_player_data(user_id: int, data: ComponentData) -> void:
    player_data[user_id] = data

