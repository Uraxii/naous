class_name DialogueOption extends Resource

@export var requires_flags:Array[StringName] ## The player needs all flags to choose this response Option.
@export var display_text:String = "..." ## Text displayed on a button, as the player's provided response.

#@export var gives_flags:Array[StringName]
#@export var emit_event_key:StringName ## If not empty, emits a signal when this Option is chosen, 
