class_name ComponentStatManager extends Node

const ID := "Stats"

var stats: Dictionary[String, ComponentStat]

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
#endregion


func find(stat_id: String) -> ComponentStat:
    var comp = stats.get(stat_id)

    if not comp:
        comp = find_child(stat_id)
        if comp and comp is ComponentStat:
            stats[comp.name] = comp

    return comp


#region Signal Handlers 
func _on_component_added(node: Node) -> void:
    if node is ComponentStat:
        stats.set(node.name, node)


func _on_component_removed(node: Node) -> void:
    stats.erase(node.name)
#endregion

#region Godot Callback Functions
func _ready() -> void:
    child_entered_tree.connect(_on_component_added)
    child_exiting_tree.connect(_on_component_removed)
#endregion
