class_name InstanceDB extends Node

const klass := preload("res://scripts/instance.gd")

var pool: Dictionary[int, klass] = {  }
var id_pool := IdPool.new()

func get_all() -> Array[klass]:
    return pool.values()


func find(item_id: int) -> klass:
    return pool.get(item_id)


func create() -> klass:
    var item := klass.new()
    item.id = id_pool.lease()

    if not item.id:
        push_error("Failed to assign id to item!")
        return

    if pool.has(item.id):
        push_error("Tried to assign an id to an item that is in use!")
        return

    pool[item.id] = item
    return item


func release(item_id: int) -> klass:
    var item: klass = pool.get(item_id)
    if item:
        pool.erase(item_id)
    id_pool.release(item_id)
    return item
