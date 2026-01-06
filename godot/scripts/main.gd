class_name Main extends Node

@onready var signals := Globals.signal_bus
@onready var arguments := Globals.launch_args

@onready var splash_screen: Control = %SplashScreen
@onready var animated_progress_bar: ProgressBar = %AnimatedProgressBar
const SPLASH_SCREEN_TIME:float = 3.0

func _initialize_client(args: Dictionary) -> void:
    print_debug("Initializing as client...")
    Globals.views.spawn(CharacterSelectView)
    


func _initialize_server(args: Dictionary) -> void:
    print("Initializing as server...")
    InstanceAPI.start_server()


func _ready() -> void:
	## Splash screen
    var splash_tween = splash_screen.create_tween()
    splash_tween.set_trans(Tween.TRANS_SINE)
    splash_tween.tween_property(splash_screen, ^"modulate", Color.WHITE, 1.0).from(Color.BLACK)
    splash_screen.show()
	
	## Loading bar false graphic.
    var loading_bar_tween = animated_progress_bar.create_tween()
    loading_bar_tween.set_ease(Tween.EASE_IN_OUT)
    loading_bar_tween.set_trans(Tween.TRANS_EXPO)
    loading_bar_tween.tween_property(animated_progress_bar, ^"value", animated_progress_bar.max_value, SPLASH_SCREEN_TIME * 0.9)
    await loading_bar_tween.finished
    splash_screen.queue_free()
	
    Globals.views.spawn(ConsoleView)

    print_debug("user://: ", OS.get_user_data_dir())
    print_debug("Args=", arguments)

    if arguments.has("server"):
        _initialize_server(arguments)
    else:
        _initialize_client(arguments)
