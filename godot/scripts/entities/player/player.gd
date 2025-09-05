class_name Player extends Entity

func _ready() -> void:
    super._ready()
    if transform_sync.is_multiplayer_authority():
        %StatView.visible = true
