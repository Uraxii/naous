class_name ActorManager extends Node

@onready var actor_db := Globals.actor_db
@onready var signals := Globals.signal_bus

## Peer ID: Actor ID
var players: Dictionary[int, int] = {  }
## Actor Instance ID: Actor
var actors: Dictionary[int, Actor] = {  }


func spawn_actor() -> void:
    pass


func update_actor_data() -> void:
    var all_actor_data: Array[ComponentData] = []

    if multiplayer.is_server():
        all_actor_data = actor_db.get_all()
    else:
        var client := Globals.client
        var resp: MsgAllPlayerData = await client.fetch(client.fetch_all_actor_data)


func on_network_tick() -> void:
    update_actor_data()


func connect_signals() -> void:
    signals.network_tick.connect(on_network_tick)


func _ready() -> void:
    connect_signals()

