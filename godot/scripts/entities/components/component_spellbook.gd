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


func cast_echo_from_inventory(echo_index: int) -> void:
    if is_instance_valid(caster.inventory):
        var echoes := caster.inventory.inventory.get_equipped_echoes()
        var echo := echoes[echo_index]
        if echo != null:
            var echo_effect := echo.effect


func get_all_spells() -> Dictionary[String, Spell]:
    var stat_nodes := find_children("*", "Spell")
    
    var map: Dictionary[String, Spell] = {}
    for s: Spell in stat_nodes:
        map[s.id] = s
        s.setup(caster)

    return map


func _setup() -> void:
    var component_manager: ComponentManager = get_parent()
    caster = component_manager.entity
    spells = get_all_spells()


func _connect_echo_inputs() -> void:
    Globals.signal_bus.action_1.connect(cast_echo_from_inventory.bind(0))
    Globals.signal_bus.action_2.connect(cast_echo_from_inventory.bind(1))
    Globals.signal_bus.action_3.connect(cast_echo_from_inventory.bind(2))
    Globals.signal_bus.action_4.connect(cast_echo_from_inventory.bind(3))


func _ready() -> void:
    _setup()
    
    _connect_echo_inputs()
