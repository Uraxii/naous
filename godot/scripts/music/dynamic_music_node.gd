@tool class_name DynamicMusicNode extends Node3D

## TESTING -- this class is Experimental. The idea is to be able to configure 
## a scene referred [DynamicMusicEvent] within the editor.

@export_tool_button("Activate", "AudioStreamPlayer") var demo = editor_demo ## This fires [method editor_demo]
@export var event: DynamicMusicEvent

func editor_demo() -> void:
	if event:
		event.activate()
