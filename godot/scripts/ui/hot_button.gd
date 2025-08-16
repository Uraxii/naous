class_name HotkeyButton extends View

@onready var spell: Spell


func set_bind(trigger: Signal) -> void:
    trigger.connect(_on_action_pressed)
    

func set_spell(new_spell: Spell) -> void:
    spell = new_spell
    
    
func _on_action_pressed() -> void:
    print_debug("Button pressed!")
    if spell:
        spell.cast()
