@tool class_name DynamicMusicNode extends Node3D

## Configure dynamic music events within the editor
## with added features that come from existing physically in the game world.
## 
## See [DynamicMusicEvent] for documentation on the [Resource].

@export_tool_button("Activate", "AudioStreamPlayer") var demo = editor_demo
@export var event: DynamicMusicEvent

func editor_demo() -> void:
	if event:
		event
