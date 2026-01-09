class_name TitleScreen
extends PanelContainer

@export_range(-12.0, 0.0, 0.5, "suffix:db") var initial_music_volume := -3.0 ## 0.71 == -3db
@export var button_presses_to_skip_intro:int = 1

const NOT_SO_STILL = preload("uid://e26byi4f045n")
const TUTORIAL = preload("uid://d33k3abfexh3k")
const CREDITS_FLYOVER = preload("uid://bovh2hjexu5yl")

var intro_finished:bool = false

const MENU_TAB := 0
const LOADING_TAB := 1
@onready var tab_container: TabContainer = %TabContainer
@onready var menu_container: MarginContainer = %MenuContainer
@onready var options_container: MarginContainer = %OptionsContainer

const SPLASH_SCREEN_TIME:float = 3.0
@onready var loading_container: MarginContainer = %LoadingContainer
@onready var animated_progress_bar: ProgressBar = %AnimatedProgressBar

@onready var start_game_button: Button = %StartGameButton
@onready var credits_button: Button = %CreditsButton
@onready var quit_game_button: Button = %QuitGameButton

@onready var local_camera: Camera3D = %Camera
@onready var texture_rect: TextureRect = %TextureRect

func _ready() -> void:
    DynamicMusicManager.set_music_bus_volume_db(initial_music_volume)
    Globals.music.start_track(NOT_SO_STILL)
    
    start_game_button.pressed.connect(start_game)
    credits_button.pressed.connect(show_credits)
    quit_game_button.pressed.connect(quit_game)
    
    tab_container.current_tab = MENU_TAB
    
    #Globals.camera.camera.global_transform = local_camera.global_transform
    local_camera.make_current() ## Camera
    _begin_background_animation()
    
var intro_tween: Tween
func _begin_background_animation() -> void:
    tab_container.modulate = Color.TRANSPARENT
    
    var target:Color = texture_rect.self_modulate ## Cache the target color from the editor config
    texture_rect.self_modulate = Color.TRANSPARENT ## Make transparent to start
    
    intro_tween = texture_rect.create_tween()
    intro_tween.set_ease(Tween.EASE_IN)
    #intro_tween.set_trans(Tween.TRANS_CUBIC)
    intro_tween.tween_interval(6.2)
    intro_tween.tween_property(texture_rect, ^"self_modulate", target, 2.2)
    
    await intro_tween.finished
    
    ## This section just makes the TextureRect pulse in opacity to add some juice.
    var background_tween = texture_rect.create_tween()
    #background_tween.set_ease(Tween.EASE_OUT)
    background_tween.set_trans(Tween.TRANS_CUBIC)
    background_tween.tween_property(texture_rect, ^"self_modulate", Color(Color.ANTIQUE_WHITE, 0.4), 3.0)
    background_tween.tween_interval(1.5)
    background_tween.tween_property(texture_rect, ^"self_modulate", target, 3.0)
    background_tween.tween_interval(1.0)
    background_tween.set_loops()

func _skip_intro() -> void:
    if intro_tween:
        if intro_tween.is_running():
            intro_tween.custom_step(INF)
    _on_intro_animation_finished()
    
func _on_intro_animation_finished() -> void:
    if intro_finished: return
    
    ## Fade in the main menu
    intro_finished = true
    var fit:Tween = create_tween()
    fit.set_ease(Tween.EASE_IN)
    fit.tween_property(tab_container, ^"modulate", Color.WHITE, 1.2)


@onready var skip_button_pressed_count:int = 0
var debouncing:bool = false
func _undebounce() -> void: debouncing = false
const DEBOUNCE_TIME:float = 0.5

func _input(event: InputEvent) -> void:
    if not intro_finished:
        if event.is_pressed():
            if not debouncing:
                debouncing = true
                var debounce:Tween = create_tween()
                debounce.tween_interval(DEBOUNCE_TIME)
                debounce.tween_callback(_undebounce)
                
                skip_button_pressed_count += 1
                print("Skip count %d" % [skip_button_pressed_count])
                #credits.throb_cancel_label(cancel_button_presses_to_quit + 1 - cancel_button_pressed_count)
                if skip_button_pressed_count > button_presses_to_skip_intro:
                    _skip_intro()


func start_game() -> void:
    if not intro_finished: return
    
    await run_splash_screen()
    get_tree().change_scene_to_packed(TUTORIAL)


func show_credits() -> void:
    if not intro_finished: return
    
    await run_splash_screen()
    get_tree().change_scene_to_packed(CREDITS_FLYOVER)


func quit_game() -> void:
    if not intro_finished: return
    
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
    loading_bar_tween.tween_property(animated_progress_bar, ^"value", animated_progress_bar.max_value, SPLASH_SCREEN_TIME * 0.9).from(animated_progress_bar.min_value)
    await loading_bar_tween.finished


func _on_options_button_pressed() -> void:
    if not intro_finished: return
    
    options_container.show()
