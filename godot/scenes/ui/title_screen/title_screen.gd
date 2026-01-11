class_name TitleScreen
extends PanelContainer

@export var music_playlist: Array[DynamicMusicTrack]
@export_range(-12.0, 0.0, 0.5, "suffix:db") var initial_music_volume := -5.0 ## decibels
@export var button_presses_to_skip_intro:int = 2
@export var idle_time_to_show_lore_tab:float = 10.0

#const NOT_SO_STILL = preload("uid://e26byi4f045n")
const TUTORIAL = preload("uid://d33k3abfexh3k")
const CREDITS_FLYOVER = preload("uid://bovh2hjexu5yl")

var intro_finished:bool = false

@onready var tab_container: TabContainer = %TabContainer
@onready var menu_container: MarginContainer = %MenuContainer
@onready var options_container: MarginContainer = %OptionsContainer
@onready var lore_container: MarginContainer = %LoreContainer
@onready var lore_scroll_container: ScrollContainer = %LoreScrollContainer

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
    Globals.music.continuous_playback = true
    tree_exiting.connect(Globals.music.set.bind(&"continuous_playback", false))
    Globals.music.start_playlist(music_playlist)
    tree_exiting.connect(Globals.music.clear_playlist)
    
    start_game_button.pressed.connect(start_game)
    credits_button.pressed.connect(show_credits)
    quit_game_button.pressed.connect(quit_game)
    
    menu_container.show()
    
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
    fit.tween_callback(reset_wait_switch_to_lore_tab) ## Start the timer


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
    elif menu_container.visible:
        ## If we're at the main menu, we'll switch to the Lore tab after the user
        ## idles for a set time.
        reset_wait_switch_to_lore_tab()
        

var idle_tween: Tween
func reset_wait_switch_to_lore_tab(on: bool = true) -> void:
    if idle_tween:
        if idle_tween.is_valid():
            idle_tween.kill()
    if on:
        idle_tween = create_tween()
        idle_tween.tween_interval(idle_time_to_show_lore_tab)
        idle_tween.tween_callback(show_lore)
    #else:
        #print("Sanity check")
    
func show_lore() -> void:
    if not menu_container.visible: return
    
    lore_scroll_container.scroll_vertical = 0
    
    var lore:Tween = create_tween()
    lore.tween_property(menu_container, ^"modulate", Color.TRANSPARENT, 2.0)
    lore.tween_property(lore_container, ^"modulate", Color.WHITE, 3.0).from(Color.TRANSPARENT)
    lore.parallel()
    lore.tween_callback(lore_container.show)
    lore.tween_interval(10.0) ## Wait to start scrolling
    #lore.tween_property(lore_scroll_container, ^"scroll_vertical", 2171, 120.0) ## HACK hard coded length
    #lore.tween_property(lore_scroll_container, ^"scroll_vertical", lore_scroll_container.scroll_vertical + 1, 0.1) ## Advance by just one
    lore.tween_callback(autoscroll_lore)
    
var autoscroller:Tween
func autoscroll_lore() -> void:
    _on_autoscroll_interrupted()
    
    autoscroller = create_tween()
    ## Advance by just one
    autoscroller.tween_callback(func(): lore_scroll_container.scroll_vertical += 1)
    autoscroller.tween_interval(0.15) ## Controls scrolling speed
    ## I dont believe we need to worry about stopping the loop.
    autoscroller.set_loops()
    
    lore_scroll_container.gui_input.connect(_on_autoscroll_interrupted)

func _on_autoscroll_interrupted(event: InputEvent = null) -> void:
    if lore_scroll_container.gui_input.is_connected(_on_autoscroll_interrupted):
        lore_scroll_container.gui_input.disconnect(_on_autoscroll_interrupted)
    
    if autoscroller:
        if autoscroller.is_running():
            autoscroller.kill()

func start_game() -> void:
    if not intro_finished: return
    
    Globals.music.stop_all_tracks()
    
    await run_splash_screen()
    get_tree().change_scene_to_packed(TUTORIAL)


func show_credits() -> void:
    if not intro_finished: return
    
    Globals.music.stop_all_tracks()
    
    await run_splash_screen()
    get_tree().change_scene_to_packed(CREDITS_FLYOVER)


func quit_game() -> void:
    if not intro_finished: return
    
    get_tree().quit()


func run_splash_screen() -> void:
    loading_container.show()
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


func _on_lore_back_button_pressed() -> void:
    menu_container.show() ## Return to the main menu
    var fit:Tween = create_tween()
    fit.tween_property(menu_container, ^"modulate", Color.WHITE, 3.0)

func _on_lore_container_visibility_changed() -> void:
    if lore_container:
        if not lore_container.visible:
            _on_autoscroll_interrupted()


func _on_tab_container_tab_changed(_tab: int) -> void:
    if tab_container:
        if not tab_container.get_current_tab_control() == menu_container:
            reset_wait_switch_to_lore_tab(false) ## Stop loading the lore
