class_name ComponentStatManager extends Node

const ID := "Stats"

var stats: Dictionary[String, ComponentStat]


func get_value(id: String) -> float:
    var comp = find(id)
    return comp.current if comp else 0.0


func get_max(id: String) -> float:
    var comp = find(id)
    return comp.max_value


func get_percent(id: String) -> float:
    var comp = find(id)
    return comp.percentage if comp else 0.0


func modify(id: String, amount: float) -> void:
    var comp = find(id)

    if not comp:
        return

    comp.current += amount


func modify_percent(id: String, percentage: float):
    var comp = find(id)

    if not comp:
        return

    comp.current = comp.current - (comp.max * percentage)


func find(id: String) -> ComponentStat:
    var comp = stats.get(id)

    if not comp:
        comp = find_child(id)
        if comp:
            stats[id] = comp

    return comp
