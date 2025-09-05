class_name ComponentSpellbook extends Node

@export_category("Runtime Values")
@export var spells: Dictionary[String, Spell] = {}
# Spell ID : Input Action String
@export var hotbutton_binds: Dictionary[String, String]

var caster: Entity


func cast(spell_id: String):
    var spell: Spell = spells.get(spell_id)
    if not spell or not spell.is_castable:
        return false

    spell.cast.rpc()
    return true
    

func get_all_spells() -> Dictionary[String, Spell]:
    var stat_nodes := get_children().filter(func(child): return child is Spell)
    
    var map: Dictionary[String, Spell] = {}
    for s: Spell in stat_nodes:
        map[s.id] = s
        s.setup(caster)

    return map


func _setup() -> void:
    var component_manager: ComponentManager = get_parent()
    caster = component_manager.entity
    spells = get_all_spells()
    
    
func _ready() -> void:
    _setup()
