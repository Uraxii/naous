class_name HUDLayer
extends CanvasLayer

signal fade_in_complete
signal fade_out_complete

@onready var fade_box: ColorRect = %FadeBox

const FADE_DURATION: float = 4
var current_tween: Tween


func hide_screen() -> void:
    fade_box.color.a = 1


func show_screen() -> void:
    fade_box.color.a = 0


func fade_in() -> void:
    fade_box.show()
    if is_instance_valid(current_tween) and current_tween.is_running():
        current_tween.stop()
    
    current_tween = create_tween()
    var fade_time := FADE_DURATION * (fade_box.color.a) # Ratio for how much to fade
    current_tween.tween_property(fade_box, "color", Color(0,0,0,0), fade_time)
    current_tween.tween_callback(_on_fade_in_complete)


func _on_fade_in_complete() -> void:
    fade_box.hide()
    fade_in_complete.emit()


func fade_out() -> void:
    fade_box.show()
    if is_instance_valid(current_tween) and current_tween.is_running():
        current_tween.stop()
    
    current_tween = create_tween()
    var fade_time := FADE_DURATION * (1 - fade_box.color.a) # Ratio for how much to fade
    current_tween.tween_property(fade_box, "color", Color(0,0,0,1), fade_time)
    current_tween.tween_callback(_on_fade_out_complete)


func _on_fade_out_complete() -> void:
    fade_out_complete.emit()
