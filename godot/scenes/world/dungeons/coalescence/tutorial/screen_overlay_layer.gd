class_name ScreenOverlayLayer
extends CanvasLayer

signal fade_in_complete
signal fade_out_complete

@onready var fade_box: ColorRect = %FadeBox

const FADE_DELAY: float = 1.7

const FADE_DURATION: float = 4.0
var current_tween: Tween


func hide_screen() -> void:
    fade_box.color.a = 1


func show_screen() -> void:
    fade_box.color.a = 0


## Fade the game view in
func fade_in(duration_override: float = -1) -> void:
    show()
    fade_box.show()
    if is_instance_valid(current_tween) and current_tween.is_running():
        current_tween.stop()
    
    current_tween = create_tween()
    var fade_duration := FADE_DURATION
    if duration_override >= 0:
        fade_duration = duration_override
    var fade_time := fade_duration * (fade_box.color.a) # Ratio for how much to fade
    current_tween.tween_interval(FADE_DELAY) ## Pause while fully black
    current_tween.tween_property(fade_box, "color", Color(0,0,0,0), fade_time)
    current_tween.tween_callback(_on_fade_in_complete)


func _on_fade_in_complete() -> void:
    hide()
    fade_box.hide()
    fade_in_complete.emit()


## Fade the game view out (to black)
func fade_out(duration_override: float = -1) -> void:
    show()
    fade_box.show()
    if is_instance_valid(current_tween) and current_tween.is_running():
        current_tween.stop()
    
    current_tween = create_tween()
    var fade_duration := FADE_DURATION
    if duration_override >= 0:
        fade_duration = duration_override
    var fade_time := fade_duration * (1 - fade_box.color.a) # Ratio for how much to fade
    current_tween.tween_property(fade_box, "color", Color(0,0,0,1), fade_time)
    current_tween.tween_interval(FADE_DELAY) ## Pause while fully black
    current_tween.tween_callback(_on_fade_out_complete)


func _on_fade_out_complete() -> void:
    fade_out_complete.emit()
