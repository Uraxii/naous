class_name ComponentStatManager extends Node

const ID := "Stats"

var data: StatsData
var stats: Dictionary[String, ComponentStat]


func setup(stats_data: StatsData) -> void:
    data = stats_data

    var data_dict := data.serialize()
    for stat_id in data_dict.keys():
        print_debug("stat: %s, val %d" % [stat_id, data_dict[stat_id]])
        set_value(stat_id, data_dict[stat_id])


#region Get Stat Values
func get_value(id: String) -> float:
    var comp = stats.get(id)
    return comp.current if comp else 0.0


func get_max(id: String) -> float:
    var comp = stats.get(id)
    return comp.max_value


func get_percent(id: String) -> float:
    var comp = stats.get(id)
    return comp.percentage if comp else 0.0
#endregion

#region Modify Stat Values
func modify(id: String, amount: float) -> void:
    var comp = stats.get(id)
    if comp:
        comp.current += amount


func modify_percent(id: String, percentage: float):
    var comp = stats.get(id)
    if comp:
        comp.current = comp.current - (comp.max * percentage)


func set_value(id: String, new_value: float) -> void:
    var comp = stats.get(id)
    if comp:
        comp.current = new_value
#endregion


func find(stat_id: String) -> ComponentStat:
    var comp = stats.get(stat_id)

    if not comp:
        comp = find_child(stat_id)
        if comp:
            stats[comp.name] = comp

    return comp


#region Signal Handlers
func _on_component_added(node: Node) -> void:
    stats.set(node.name, node)


func _on_component_removed(node: Node) -> void:
    stats.erase(node.name)
#endregion

#region Godot Callback Functions
func _ready() -> void:
    child_entered_tree.connect(_on_component_added)
    child_exiting_tree.connect(_on_component_removed)
#endregion
