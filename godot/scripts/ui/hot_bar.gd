class_name HotkeyBar extends View

@export var binds := ["action_1", "action_2", "action_3", "action_0"]

var buttons: Array[HotkeyButton] = []


func _ready() -> void:
    signals.control_entity.connect(_on_control)
    
    for i in range(0, binds.size()):
        var button = HotkeyButton.new()
        button.set_bind(signals.get(binds[i]))
        buttons.append(button)
        add_child(button)


func _on_control(new_enity: Entity) -> void:
    if not new_enity.spells:
        return
    
    var spells: Array[Spell] = new_enity.spells.spells.values()
    
    for i in range(spells.size()):
        buttons[i].set_spell(spells[i])
