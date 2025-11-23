class_name HUDLayer
extends CanvasLayer

@onready var quest_heading: Label = %QuestHeading
@onready var quest_details: Label = %QuestDetails
@onready var interact_prompt: PanelContainer = %InteractPrompt
@onready var interact_text: Label = %InteractText


func detected_interactable(entity: Entity, interactable: InteractableComponent) -> void:
    if entity.is_local_owner:
        var interact_prompt_text := interactable.prompt_text
        interact_text.text = interact_prompt_text
        interact_prompt.show()


func lost_interactable(entity: Entity, interactable: InteractableComponent) -> void:
    if entity.is_local_owner:
        interact_prompt.hide()
        interact_text.text = ""


func _ready() -> void:
    Globals.signal_bus.entity_detected_interactable.connect(detected_interactable)
    Globals.signal_bus.entity_lost_interactable.connect(lost_interactable)
    
    interact_prompt.hide()
