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


func find(id: int) -> Entity:
    return pool.get(id)


func _on_client_spawn(node: Node) -> void:
    if node is Entity:
        # Register the entity in the pool.
        pool[node.id] = node as Entity
        signals.log_new_debug.emit("Registered %s as %d" % [node.name, node.id])


#region Godot Callback Functions
func _ready():
    spawn_function = Callable(self, "_spawn_custom")
    spawned.connect(_on_client_spawn)


func _spawn_custom(data: Dictionary) -> Node:
    # TODO: CHANGE THIS!!! PLAYERS SHOULD NOT BE ABLE TO PASS IN AN ABITRARY PATH!!!
    var scene = load(data.scene)
    var entity: Entity = scene.instantiate()
    
    if data.get("type") == "player":
        entity.transform_sync.set_multiplayer_authority(data.authority)
        entity.name = data.id
        
    if data.has("position"):
        print_debug("Set entity pos to %s" % data.position)
        entity.position = data.position
        

    var id = _ids.lease()
    entity.id = id
    pool[id] = entity

    signals.spawn_entity.emit(entity)
    return entity
#endregion
