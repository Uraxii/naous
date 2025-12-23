class_name PromiseManager extends Node

var pending_promises: Dictionary[int, Promise] = {  }
var id_pool := IdPool.new()


func create() -> Promise:
    var id := id_pool.lease()
    var promise := Promise.new(id)
    pending_promises[promise.id] = promise
    return promise


func fulfill(id: int, data) -> void:
    var promise: Promise = pending_promises.get(id)
    if promise:
        promise.trigger.emit(data)
