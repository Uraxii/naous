class_name StatsComponent extends Node

@onready var stats: Dictionary[String, StatComponent] = get_all_stats()


func get_stat(stat_id: String) -> StatComponent:
    if not stats.has(stat_id):
        stats = get_all_stats()

    return stats.get(stat_id)


func get_all_stats() -> Dictionary[String, StatComponent]:
    # Get any child that is of type StatComponent
    var stat_nodes := get_children().filter(func(child): return child is StatComponent)

    var map: Dictionary[String, StatComponent] = {}
    for s: StatComponent in stat_nodes:
        map[s.name] = s

    return map
