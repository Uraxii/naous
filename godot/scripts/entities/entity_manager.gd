class_name EntityManager extends MultiplayerSpawner

@export var player_scene: PackedScene = preload(
    "uid://c5ospakgw0cwt")

@onready var signals: SignalBus = Globals.signal_bus
@onready var lg: Log = Globals.logger

var pool: Dictionary[int, Entity] = {}
var _ids := IdPool.new()


@rpc("call_local", "any_peer")
func despawn(id: int) -> void:
    if not multiplayer.is_server():
        return

    var entity: Entity = pool.get(id)
    pool.erase(id)

    if not entity or not entity.is_inside_tree():
        return

    entity.queue_free.call_deferred()
    #lg.debug(entity)


func find(id: int) -> Entity:
    return pool.get(id)


func _on_client_spawn(node: Node) -> void:
    if node is Entity:
        # Register the entity in the pool.
        pool[node.id] = node as Entity
        #lg.debug("Registered %s as %d" % [node.name, node.id])


#region Godot Callback Functions
func _ready():
    spawn_function = Callable(self, "_spawn_custom")
    spawned.connect(_on_client_spawn)


func _spawn_custom(serialized_spawn_msg: Dictionary) -> Node:
    # TODO: CHANGE THIS!!! PLAYERS SHOULD NOT BE ABLE TO PASS IN AN ABITRARY PATH!!!
    var msg := MsgSpawnEntity.new()
    msg.deserialize(serialized_spawn_msg.payload)
    
    var scene = load(msg.resource_path)
    var entity: Entity = scene.instantiate()

    match entity.type:
        entity.EntityType.PLAYER:
            entity.transform_sync.set_multiplayer_authority(msg.authority)
            entity.name = "%d" % msg.id
            entity.display_name = msg.display_name

    var id = _ids.lease()
    entity.id = id
    pool[id] = entity

    signals.spawn_entity.emit(entity)
    return entity
#endregion
