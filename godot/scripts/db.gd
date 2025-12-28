class_name DB extends Node


## Peer ID: PlayerData
var player_data: Dictionary[int, ComponentData] = {  }
var actor_db := ActorDB.new()
var instances := InstanceDB.new()


## Returns Array[Intance] containing all instance data.
func fetch_all_instances() -> Array[Instance]:
    return instances.get_all()


func fetch_instance(instance_id: int) -> void:
    return instances.find(instance_id)


## Returns ID of created Instance on success, otherwise 0.
func create_instance(scene: String) -> int:
    return 0


## Returns Array[ComponentData] containing all player data.
func get_all_player_data() -> Array[ComponentData]:
    return player_data.values()


## Returns player data of [param user_id].
func get_player_data(user_id: int) -> ComponentData:
    return player_data.get(user_id)


## Sets the player data for [param user_id].
func set_player_data(user_id: int, data: ComponentData) -> void:
    player_data[user_id] = data

