class_name DynamicMusicEventTransitionsConfig extends Resource

## TESTING -- this class is Experimental. Related to [DynamicMusicEvent].
## The idea was to make a resource that can be "fired" as an event in the
## dynamic music system. This would be used in scripts to react to gameplay
## and apply some desired effect to the music.
	
@export_range(-1.0, 30.0, 0.1,"or_greater") var transition_in:float = 1.0
@export_range(0.1, 10.0, 0.1, "or_greater", "hide_slider") var duration:float = 3.0 ## Only applies to Duration [member mode].
@export_range(-1.0, 30.0, 0.1,"or_greater") var transition_out:float = 1.0 ## in seconds. Does not apply to One-shot [member mode].
