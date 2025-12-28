class_name Main extends Node

@onready var arguments := Globals.launch_args


func _ready() -> void:
    print_debug("user://: ", OS.get_user_data_dir())
    print_debug("Args=", arguments)

