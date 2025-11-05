class_name DialogueUI extends Control

## Handles populating the user interface using external resources, and
## signals for, or triggers external game events relevant to dialogue outcomes.


#region --Signals
#endregion


#region --Variables
# statics
# Enums
# constants
# @exports
@export var dialogue:PackedDialogue
# public
# _private
# @onready
@onready var speaker_name: Label = %SpeakerName
@onready var narration: RichTextLabel = %Narration
@onready var instruction: Label = %Instruction
@onready var options_v_box: VBoxContainer = %OptionsVBox
@onready var template_option: Button = %TemplateOption

#endregion


#region --Virtuals
#func _init() -> void: pass
#func _enter_tree() -> void: pass
#func _ready() -> void: pass
#func _input(event: InputEvent) -> void: pass
#func _unhandled_input(event: InputEvent) -> void: pass
#func _physics_process(delta: float) -> void: pass
#func _process(delta: float) -> void: pass
#endregion
#region --Public Methods
#endregion
#region --Private Methods
#endregion
#region --Events
#endregion
