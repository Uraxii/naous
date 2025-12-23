class_name IdPool

const INVALID_ID := 0

var active:     Array[int] = []
var inactive:   Array[int] = []

var _incrementer := INVALID_ID


func lease() -> int:
    if active.size() > 0:
        return active.pop_front()

    _incrementer += 1
    return _incrementer


func release(id: int) -> void:
    if not inactive.has(id):
        inactive.append(id)

