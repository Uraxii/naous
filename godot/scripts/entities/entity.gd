class_name Entity extends Node3D

#region Variables
const INVALID_ID: int = -1

# @export var data := EntityData.new()
@export var body: CharacterBody3D
@export_category("Runtime Values")
@export var id: int = INVALID_ID
@export var local_has_control := false

@onready var entities := Globals.entities
@onready var stats: Dictionary[String, Stat] = get_all_stats()
#endregion

#region Stats
func get_stat(stat_id: String) -> Stat:
    if not stats.has(stat_id):
        stats = get_all_stats()

    return stats.get(stat_id)


func get_all_stats() -> Dictionary[String, Stat]:
    var container := find_child("Stats")
    # Get any child that is of type Stat
    var stat_nodes := container.get_children().filter(
        func(child): return child is Stat)

    var map: Dictionary[String, Stat] = {}
    for s: Stat in stat_nodes:
        map[s.name] = s

    return map
#endregion

#region Godot Callback Functions
func _ready() -> void:
    entities.spawn(self)


func _exit_tree() -> void:
    entities.despawn(self)
#endregion
