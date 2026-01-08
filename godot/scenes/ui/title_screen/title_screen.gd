class_name TitleScreen
extends PanelContainer

@export var music_volume_ratio := 0.3

const NOT_SO_STILL = preload("uid://e26byi4f045n")
const TUTORIAL = preload("uid://d33k3abfexh3k")
const CREDITS_FLYOVER = preload("uid://bovh2hjexu5yl")

const MENU_TAB := 0
const LOADING_TAB := 1
@onready var tab_container: TabContainer = %TabContainer
@onready var menu_container: MarginContainer = %MenuContainer

const SPLASH_SCREEN_TIME:float = 3.0
@onready var loading_container: MarginContainer = %LoadingContainer
@onready var animated_progress_bar: ProgressBar = %AnimatedProgressBar

@onready var start_game_button: Button = %StartGameButton
@onready var credits_button: Button = %CreditsButton
@onready var quit_game_button: Button = %QuitGameButton

@onready var local_camera: Camera3D = %Camera
@onready var texture_rect: TextureRect = %TextureRect


func start_game() -> void:
    await run_splash_screen()
    get_tree().change_scene_to_packed(TUTORIAL)


func show_credits() -> void:
    await run_splash_screen()
    get_tree().change_scene_to_packed(CREDITS_FLYOVER)


func quit_game() -> void:
    get_tree().quit()


func run_splash_screen() -> void:
    tab_container.current_tab = LOADING_TAB
    ## Splash screen
    var splash_tween = loading_container.create_tween()
    splash_tween.set_trans(Tween.TRANS_SINE)
    splash_tween.tween_property(loading_container, ^"modulate", Color.WHITE, 1.0).from(Color.BLACK)
    
    ## Loading bar false graphic.
    var loading_bar_tween = animated_progress_bar.create_tween()
    loading_bar_tween.set_ease(Tween.EASE_IN_OUT)
    loading_bar_tween.set_trans(Tween.TRANS_EXPO)
    loading_bar_tween.tween_property(animated_progress_bar, ^"value", animated_progress_bar.max_value, SPLASH_SCREEN_TIME * 0.9)
    await loading_bar_tween.finished


func _ready() -> void:
    DynamicMusicManager.set_music_bus_volume(music_volume_ratio)
    Globals.music.start_track(NOT_SO_STILL)
    
    start_game_button.pressed.connect(start_game)
    credits_button.pressed.connect(show_credits)
    quit_game_button.pressed.connect(quit_game)
    
    tab_container.current_tab = MENU_TAB
    
    #Globals.camera.camera.global_transform = local_camera.global_transform
    local_camera.make_current() ## Camera
    
    ## This section just makes the TextureRect pulse in opacity to add some juice.
    var target:Color = texture_rect.self_modulate ## Cache the target from the editor config
    texture_rect.self_modulate = Color.WHITE ## Make opaque to start
    var background_tween = texture_rect.create_tween()
    #background_tween.set_ease(Tween.EASE_OUT)
    background_tween.set_trans(Tween.TRANS_CUBIC)
    background_tween.tween_property(texture_rect, ^"self_modulate", target, 3.0) #.from(Color.WHITE)
    background_tween.tween_interval(1.0 + randf())
    background_tween.tween_property(texture_rect, ^"self_modulate", Color(Color.WHITE, randf()*0.6), 3.0 + randf())
    background_tween.tween_interval(randf())
    background_tween.set_loops()
