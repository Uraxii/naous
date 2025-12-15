class_name HotbarView extends View

@onready var hbox: HBoxContainer = %HBox

var id := 1

var binds := [
    InputBindings.ACTION_1,
    InputBindings.ACTION_2,
    InputBindings.ACTION_3,
    InputBindings.ACTION_4,
]

var buttons: Array[Hotbutton] = []


func _on_control_entity(new_enity: Entity) -> void:
    var spell_component = new_enity.spellbook
    #log.debug("sb", new_enity.spellbook)
    if not spell_component:
        return

    var spells: Array[Spell] = spell_component.spells.values()
    #log.debug("Spells:", spells)
    #log.debug("Hotbuttons: ", buttons)

    for button in buttons:
        for spell in spells:
            print_debug("Spell: ", spell.name, ", ", spell.hotbutton)
            if spell.hotbutton == button.id:
                log.debug("(%s, %d, %d)" % [spell.id, spell.hotbutton, button.id])
                button.set_spell(spell)


func _ready() -> void:
    signals.control_entity.connect(_on_control_entity)
    for i in range(0, binds.size()):
        var button: Hotbutton = views.spawn(Hotbutton)
        var button_id = i + 1
        var action = binds[i]
        button.setup(button_id, action)
        buttons.append(button)
        button.reparent(hbox)
