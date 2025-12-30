class_name ActorDB extends Node

const ACTOR_SCENE := preload("res://scenes/entities/player.tscn")

@onready var signals := Globals.signal_bus

## Peer ID : Entity Instance ID
var players: Dictionary[int, int] = {  }
## Entity id : Actor
var actors: Dictionary[int, Entity] = {  }
## Pooler for managing instance IDs
var id_pool := IdPool.new()


## Creates an actor on the clients.
## Called by the sever on a client.
@rpc("authority", "call_local", "reliable")
func create_actor(data: Dictionary) -> void:
    var actor := ACTOR_SCENE.instantiate()
    actor.components.deserialize(data)
    actor.name = str(actor.id)
    add_child.call_deferred(actor)


## Destroys an actor on the clients.
## Called by the sever on a client.
@rpc("authority", "call_remote", "reliable")
func destroy_actor(id: int) -> void:
    pass


## Updates actor data on the clients.
## Called by the sever on a client.
@rpc("authority", "call_remote", "reliable")
func update_stat(id: int, data: Dictionary) -> void:
    pass


## Assigns actor instance of [param actor_id] to peer [param peer_id].
## Returns BFT.Err.OK on success.
func assign_peer(actor_id: int, peer_id: int) -> BFT.Err:
    var actor: Entity = actors.get(actor_id)
    if not actor:
        return BFT.Err.ERR_ACTOR_NOT_FOUND

    actor.peer_auth = peer_id
    players.get_or_add(peer_id, actor_id)
    return BFT.Err.OK


func get_all() -> Array[Entity]:
    return actors.values()


func find(item_id: int) -> Entity:
    return actors.get(item_id)


func create() -> Entity:
    var item: Entity = ACTOR_SCENE.instantiate()
    item.id = id_pool.lease()

    if not item.id:
        push_error("Failed to assign id to item!")
        return

    if actors.has(item.id):
        push_error("Tried to assign an id to an item that is in use!")
        return

    actors[item.id] = item
    return item


func release(item_id: int) -> Entity:
    var item: Entity = actors.get(item_id)
    if item:
        actors.erase(item_id)
    id_pool.release(item_id)
    return item
