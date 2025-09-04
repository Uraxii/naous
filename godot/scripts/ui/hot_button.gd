class_name HotButton extends View

var id := -1
var spell: Spell
var entity: Entity
var input_action: String
var current_signal: Signal


func setup(button_id: int, action: String, new_spell: Spell, new_entity: Entity) -> void:
    id = button_id
    
    if current_signal and current_signal.is_connected(_on_action_pressed):
        current_signal.disconnect(_on_action_pressed)
        
    input_action = action
    current_signal = signals.get(input_action)
    if current_signal:
        current_signal.connect(_on_action_pressed)
    
    spell = new_spell
    entity = new_entity


func _on_action_pressed() -> void:
    if entity and spell and spell.is_castable:
        InstanceAPI.request_cast.rpc_id(1, entity.id, spell.id)
