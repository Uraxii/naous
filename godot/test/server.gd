class_name Server extends Node

const PEER_ID := 1

@onready var lg := Globals.logger

var db := Database.new()

var sender_id: int:
    get: return multiplayer.get_remote_sender_id()


## Called by the server, implemented on the client.
@rpc("authority", "call_remote", "reliable")
func Return(promise_id: int, data: Dictionary) -> void:
    pass


## Fetches all player data from the database.
## Called by the client, implemented on the server.
@rpc("any_peer", "call_remote", "reliable")
func fetch_all_player_data(promise_id: int) -> void:
    var all_players := db.get_all_player_data()

    lg.debug(promise_id)

    var msg := MsgAllPlayerData.new()
    msg.promise_id = promise_id
    for player in all_players:
        msg.player_data.append(player.serialize())

    Return.rpc_id(sender_id, promise_id, Serializer.to_dict(msg))


## Fetches player data from the database.
## Called by the client, implemented on the server.
@rpc("any_peer", "call_remote", "reliable")
func fetch_player_data(promise_id: int, user_id: int) -> void:
    var data = db.get_player_data(user_id).serialize()
    Return.rpc_id(sender_id, promise_id, data)


@rpc("any_peer", "call_remote", "reliable")
func set_player_data(data: Dictionary) -> void:
    var player_data := ComponentData.new().deserialize(data)
    db.set_player_data(sender_id, player_data)

