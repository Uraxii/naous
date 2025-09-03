class_name HotBar extends View

var binds := [
    InputBindings.ACTION_1,
    InputBindings.ACTION_2,
    InputBindings.ACTION_3,
    InputBindings.ACTION_0]

var buttons: Array[HotButton] = []


func _ready() -> void:
    signals.control_entity.connect(_on_control)
    
    for i in range(0, binds.size()):
        var button = HotButton.new()
        buttons.append(button)
        add_child(button)


func _on_control(new_enity: Entity) -> void:
    var spell_component = new_enity.get_component(ComponentSpell)
    if not spell_component:
        return
    
    var spells: Array[Spell] = spell_component.spells.values()
    
    for i in range(spells.size()):
        var action_str = binds[i] if i < binds.size() else ""
        buttons[i].setup(action_str, spells[i], new_enity)
