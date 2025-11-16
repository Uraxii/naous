extends Node2D

@export var dialogue_pack: PackedDialogue
@onready var dialogue: DialogueUI = $Dialogue

func _on_start_button_pressed() -> void:
	dialogue.start_dialogue(dialogue_pack)


func _on_advance_button_pressed() -> void:
	dialogue.next()
