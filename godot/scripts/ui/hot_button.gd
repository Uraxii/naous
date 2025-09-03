class_name HotButton extends View

@onready var spell: Spell

var entity: Entity
var input_action: String
var current_signal: Signal


func setup(new_action: String, new_spell: Spell, new_entity: Entity) -> void:
    if current_signal and current_signal.is_connected(_on_action_pressed):
        current_signal.disconnect(_on_action_pressed)
        
    input_action = new_action
    current_signal = signals.get(input_action)
    if current_signal:
        current_signal.connect(_on_action_pressed)
    
    spell = new_spell
    entity = new_entity


func _on_action_pressed() -> void:
    print_debug("Button pressed!")
    if entity and spell and spell.can_cast():
        InstanceAPI.request_cast.rpc_id(1, entity.id, spell.id)
