class_name StatsComponent extends Node

@onready var stats: Dictionary[String, Stat] = get_all_stats()


func get_stat(stat_id: String) -> Stat:
    if not stats.has(stat_id):
        stats = get_all_stats()

    return stats.get(stat_id)


func get_all_stats() -> Dictionary[String, Stat]:
    # Get any child that is of type Stat
    var stat_nodes := get_children().filter(func(child): return child is Stat)

    var map: Dictionary[String, Stat] = {}
    for s: Stat in stat_nodes:
        map[s.name] = s

    return map
