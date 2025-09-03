class_name EntityManager extends MultiplayerSpawner

@export var player_scene: PackedScene = preload(
    "res://scenes/entities/player.tscn")

var signals: SignalBus:
    get: return Globals.signal_bus

var pool: Dictionary[int, Entity] = {}
var _ids := IdPool.new()


@rpc("call_local")
func despawn(id: int) -> void:
    if not multiplayer.is_server():
        return

    var entity: Entity = pool.get(id)
    pool.erase(id)

    if not entity or not entity.is_inside_tree():
        return

    entity.queue_free.call_deferred()
    signals.despawn_entity.emit(entity)


func _on_client_spawn(node: Node) -> void:
    if node is Entity:
        # Register the entity in the pool.
        pool[node.id] = node as Entity
        signals.log_new_debug.emit("Registered %s as %d" % [node.name, node.id])


#region Godot Callback Functions
func _ready():
    spawn_function = Callable(self, "_spawn_custom")
    spawned.connect(_on_client_spawn)


func _spawn_custom(data) -> Node:
    var entity: Entity = player_scene.instantiate()
    entity.body.position.z -= 30
    entity.transform_sync.set_multiplayer_authority(data.authority)
    entity.name = data.id

    var id = _ids.lease()
    entity.id = id
    pool[id] = entity

    signals.spawn_entity.emit(entity)
    return entity
#endregion
