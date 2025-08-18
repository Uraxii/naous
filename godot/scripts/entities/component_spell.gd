class_name ComponentSpell extends Node

@export var entity: Entity
@export_category("Runtime Values")
@export var spells: Dictionary[String, Spell] = {}


func get_all_spells() -> Dictionary[String, Spell]:
    var stat_nodes := get_children().filter(func(child): return child is Spell)

    var map: Dictionary[String, Spell] = {}
    for s: Spell in stat_nodes:
        map[s.id] = s
        s.setup(entity)

    print_debug(map)

    return map


func _ready() -> void:
    spells = get_all_spells()
