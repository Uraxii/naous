class_name CharacterInfoTemplate extends Button

@onready var signals := Globals.signal_bus

var character_data: Dictionary = {}


func set_character_data(character_dict: Dictionary) -> void:
    character_data = character_dict
    %Name.text = character_data.get("display_name", "{ NO NAME }")


func _on_pressed() -> void:
    signals.selected_character.emit(character_data)


func _ready() -> void:
    pressed.connect(_on_pressed)
