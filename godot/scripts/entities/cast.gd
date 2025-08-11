class_name SpellComponent extends Node

@export var entity: Entity
@export_category("Runtime Values")
@export var spells: Dictionary[String, Spell] = {}

@onready var input := Globals.input
@onready var actions: Dictionary[String, String] = {
    "action_0": "Test Spell",
}


# TODO: Simplify this process.
func handle_cast_input() -> void:
    for action_string in actions.keys():
        if input.actions.get(action_string):
            var spell_id = actions[action_string]
            var spell = spells.get(spell_id)
            print_debug(spell)
            if spell:
                spell.cast()
                print_debug("%s pressed." % action_string)


func get_all_spells() -> Dictionary[String, Spell]:
    var stat_nodes := get_children().filter(func(child): return child is Spell)

    var map: Dictionary[String, Spell] = {}
    for s: Spell in stat_nodes:
        map[s.id] = s

    return map


func _ready() -> void:
    spells = get_all_spells()


func _process(_delta: float) -> void:
    if entity.local_has_control:
        handle_cast_input()
