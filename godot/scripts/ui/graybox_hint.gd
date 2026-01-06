class_name GrayboxHint
extends Label3D


func _ready() -> void:
    # These hints are only for level development purposes. Hide/Delete them when running the actual game
    if not Engine.is_editor_hint():
        queue_free()
