class_name EntityManager extends MultiplayerSpawner

@export var player_scene: PackedScene = preload("res://scenes/entity.tscn")

var signals: SignalBus:
    get: return Globals.signal_bus

var pool: Dictionary[int, Entity] = {}
var _ids := IdPool.new()


func despawn(id: int) -> void:
    var entity: Entity = pool.get(id)
    pool.erase(id)
    
    if entity.is_inside_tree():
        entity.queue_free.call_deferred()
    
    signals.despawn_entity.emit(entity)
    

#region Godot Callback 
func _ready():
    spawn_function = Callable(self, "_spawn_custom")


func _spawn_custom(data) -> Node:
    var entity = player_scene.instantiate()
    entity.set_multiplayer_authority(data.authority)
    entity.name = data.id
    var id = _ids.lease()
    entity.id = id
    pool[id] = entity
    signals.spawn_entity.emit(entity)
    return entity
#endregion
