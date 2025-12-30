class_name Player extends Entity

@onready var is_client: bool = transform_sync.is_multiplayer_authority()

var character_data: Dictionary
var active_character: String = ""


func get_type() -> EntityType:
    return EntityType.PLAYER


func _ready() -> void:
    super._ready()
    if is_client:
        %StatView.visible = true
        #load_character_from_disk(active_character)
    #Globals.signal_bus.save_game.connect(save_active_character_to_disk)
