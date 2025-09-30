class_name DynamicMusicEventTransitionsConfig extends Resource
	
@export_range(-1.0, 30.0, 0.1,"or_greater") var transition_in:float = 1.0
@export_range(0.1, 10.0, 0.1, "or_greater", "hide_slider") var duration:float = 3.0 ## Only applies to Duration [member mode].
@export_range(-1.0, 30.0, 0.1,"or_greater") var transition_out:float = 1.0 ## in seconds. Does not apply to One-shot [member mode].
