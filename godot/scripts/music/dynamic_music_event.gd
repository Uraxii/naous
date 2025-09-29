class_name DynamicMusicEvent extends Resource

signal activated
signal deactivated

enum BUS_FX {
	NONE,
	BANDPASS,
}

@export_enum("One-shot", "Duration", "Toggle") var activation:int
@export var bus_effect:BUS_FX = BUS_FX.NONE

func activate() -> void:
	pass
