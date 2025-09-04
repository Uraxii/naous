class_name Hotbutton extends View

@onready var button: Button = %Button
@onready var label: Label = %Label

var id := -1
var spell: Spell
var timer: Timer
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
    
    entity = new_entity
    spell = new_spell
    spell.cast_started.connect(_on_cast_started)
    spell.timer.timeout.connect(_on_timer_timout)
    label.text = spell.id

#region Signal Handlers
func _on_action_pressed() -> void:
    if entity and spell and spell.is_castable:
        InstanceAPI.request_cast.rpc_id(1, entity.id, spell.id)

        
func _on_cast_started() -> void:
    # TODO: Show progress
    button.disabled = true
    label.text = "CD"
    

func _on_timer_timout() -> void:
    button.disabled = false
    label.text = spell.id
#endregion

func _ready() -> void:
    button.pressed.connect(_on_action_pressed)
    pass
