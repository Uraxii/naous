class_name ComponentSpellbook extends Node

const ID := "Spellbook"

@export_category("Runtime Values")
@export var spells: Dictionary[String, Spell] = {}
# Spell ID : Input Action String
@export var hotbutton_binds: Dictionary[String, String]

var caster: Entity


func setup(entity: Entity, data: SpellbookData) -> void:
    caster = entity
    for spell_data in data.spells:
        add_spell(spell_data)


func cast(spell_id: String):
    var spell: Spell = spells.get(spell_id)
    if not spell or not spell.is_castable:
        return false

    spell.cast.rpc()
    return true


func cast_echo_from_inventory(echo_index: int) -> void:
    if is_instance_valid(caster.inventory):
        var echoes = caster.inventory.inventory.get_equipped_echoes()
        var echo = echoes[echo_index]
        if echo != null:
            var echo_effect = echo.effect
            echo_effect.entity_triggered_effect(caster)


func add_spell(spell_data: SpellData) -> Spell:
    var spell := Spell.new()
    spell.setup(spell_data, caster)
    spell.name = spell.id
    spells[spell.id] = spell
    add_child.call_deferred(spell)
    return spell


func _connect_echo_inputs() -> void:
    Globals.signal_bus.action_1.connect(cast_echo_from_inventory.bind(0))
    Globals.signal_bus.action_2.connect(cast_echo_from_inventory.bind(1))
    Globals.signal_bus.action_3.connect(cast_echo_from_inventory.bind(2))
    Globals.signal_bus.action_4.connect(cast_echo_from_inventory.bind(3))


func _ready() -> void:
    _connect_echo_inputs()
