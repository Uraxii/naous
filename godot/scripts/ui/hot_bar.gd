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


func _ready() -> void:
    print_debug("Hotbar")
    signals.control_entity.connect(_on_control.call_deferred)
    
    for i in range(0, binds.size()):
        var button: Hotbutton = views.spawn(Hotbutton)
        buttons.append(button)
        button.reparent(hbox)


func _on_control(new_enity: Entity) -> void:
    var spell_component = new_enity.spellbook
    if not spell_component:
        return
    
    var spells: Array[Spell] = spell_component.spells.values()
    var next_button_id = 0
    # TODO: HotbarPrefs
    for i in range(spells.size()):
        var action_str = binds[i] if i < binds.size() else "OUT_OF_ACTIONS"
        buttons[i].setup(next_button_id, action_str, spells[i], new_enity)
        next_button_id += 1
