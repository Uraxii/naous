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
## This should be a single "frame" of the dialogue, a vertical slice, rather than the entire sequence.
## It can be easily checked/synced in that way.
## Maybe not necessary but structurally it is only a slight abstraction
var dialogue_history: Array[DialogueState]
var current_dialogue_state: DialogueState

# _private

# @onready
@onready var ui_speaker_name: Label = %SpeakerName
@onready var ui_narration: RichTextLabel = %Narration
@onready var ui_instruction: Label = %Instruction
@onready var ui_options_v_box: VBoxContainer = %OptionsVBox
@onready var ui_template_option: Button = %TemplateOption

#endregion

class DialogueState:
	var this: DialogueTreeItem
	var showing_options: bool
	#var last_option_chosen: int


#region --Virtuals
#func _init() -> void: pass
#func _enter_tree() -> void: pass
func _ready() -> void:
	ui_template_option.hide()
	hide()
	
#func _input(event: InputEvent) -> void: pass
#func _unhandled_input(event: InputEvent) -> void: pass
#func _physics_process(delta: float) -> void: pass
#func _process(delta: float) -> void: pass
#endregion
#region --Public Methods
## Loads a given dialogue and brings up the UI for the player to interact with.
func start_dialogue(_dialogue: PackedDialogue) -> void:
	clear()
	dialogue = _dialogue
	dialogue.current_tree = dialogue.starting_tree
	next()
	
func clear() -> void:
	# State
	current_dialogue_state = DialogueState.new()
	current_dialogue_state.showing_options = false
	
	# UI
	ui_speaker_name.text = ""
	ui_narration.text = "..."
	clear_options()
	
func clear_options() -> void:
	for child in ui_options_v_box.get_children():
		if child != ui_template_option:
			child.queue_free()
	
func next() -> void:
	clear_options()
	if not visible: show()
	
	if dialogue:
		var tree_item = dialogue.trees[dialogue.current_tree].get_current()
		if tree_item != null:
			current_dialogue_state.this = tree_item
			
			var narration = tree_item.get_next_narration()
			if narration:
				populate_narration(narration)
				
			if tree_item.on_last_narration():
				populate_options(tree_item.options)
			else:
				# Show an advance button?
				# This could become just any mouse click or something.
				add_next_option_buttion()
			
		else:
			# completed tree item
			pass
	
func populate_narration(narration: DialogueNarration) -> void:
	if narration.speaker:
		# only updates if populated otherwise assumes last speaker
		ui_speaker_name.text = narration.speaker
	
	ui_narration.text = narration.display_text
	
func add_next_option_buttion() -> void:
	var next_button: Button = ui_template_option.duplicate()
	next_button.text = "(continue)"
	next_button.visible = true
	next_button.disabled = false
	next_button.pressed.connect(next)
	ui_options_v_box.add_child(next_button)
	
func populate_options(options: Array[DialogueOption]) -> void:
	var id:int = 0
	for option:DialogueOption in options:
		var new_option: Button = ui_template_option.duplicate()
		new_option.text = option.display_text
		new_option.visible = true
		
		if option.requires_flags.is_empty():
			new_option.disabled = false
		else:
			# check flags
			new_option.disabled = true # TODO HACK
		
		ui_options_v_box.add_child(new_option)
		new_option.pressed.connect(_on_option_pressed.bind(id))
		id += 1
	
#endregion
#region --Private Methods
#endregion
#region --Events
func _on_option_pressed(idx: int) -> void:
	clear_options()
	# next tree item
	var tree_item = dialogue.trees[dialogue.current_tree].get_next()
	if tree_item != null:
		current_dialogue_state.this = tree_item
		next()
	else:
		# end
		print("End of dialogue tree")

func _on_dialogue_exit() -> void:
	clear()
	hide()
#endregion
