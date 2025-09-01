class_name EntityManager extends Node

@onready var signals := Globals.signal_bus

var active: Dictionary[int, Entity] = {}
var _ids := IdPool.new()


func spawn(entity: Entity) -> void:
    if entity in active.values():
        return

    var id = _ids.lease()
    entity.id = id
    active[id] = entity
    print_debug("Spawned entity with id %d" % entity.id)
    signals.spawn_entity.emit(entity)


func despawn(entity: Entity) -> void:
    active.erase(entity.id)
    print_debug("despawned entity with id %d" % entity.id)
    
    if entity.is_inside_tree():
        entity.queue_free.call_deferred()
        
    signals.despawn_entity.emit(entity)
