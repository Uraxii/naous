class_name Promise

signal trigger(data)

## Value for invalid ID.
const BAD_ID := -1

## Default is bad value.
var id := BAD_ID


func _init(promise_id := id) -> void:
    self.id = promise_id

