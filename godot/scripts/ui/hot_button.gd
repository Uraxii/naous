class_name Hotbutton extends View

const NO_SPELL_ID := "NO_ID"

@onready var button: Button = %Button
@onready var label: Label = %Label
@onready var icon: TextureRect = %Icon

var id := -1
var spell: Spell
var timer: Timer
var entity: Entity
var input_action: String
var current_signal: Signal


func setup(button_id: int, action: String) -> void:
    id = button_id

    if current_signal and current_signal.is_connected(_on_action_pressed):
        current_signal.disconnect(_on_action_pressed)

    input_action = action
    current_signal = signals.get(input_action)
    if current_signal:
        current_signal.connect(_on_action_pressed)


func set_spell(new_spell: Spell) -> void:
    spell = new_spell
    entity = spell.caster
    spell.cast_started.connect(_on_cast_started)
    spell.timer.timeout.connect(_on_timer_timout)
    label.text = spell.id if spell.id else NO_SPELL_ID
    if spell.icon:
        icon.texture = spell.icon


func remove_spell() -> void:
    spell.cast_started.disconnect(_on_cast_started)
    spell.timer.timeout.disconnect(_on_timer_timout)
    spell = null
    entity = null
    label.text = ""


#region Signal Handlers
func _on_action_pressed() -> void:
    if not spell:
        return

    #log.debug('Cast %s' % spell.name )
    spell.request_cast()


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
