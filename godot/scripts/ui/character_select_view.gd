class_name CharacterSelectView extends View

var character_info_template := preload(
    "res://scenes/ui/character_info_template.tscn")

var current_character: Dictionary = {}
var character_buttons: Array[CharacterInfoTemplate] = []


func populate_character_list() -> void:
    for button in character_buttons:
        button.queue_free()

    character_buttons.clear()

    var characters := save.get_all_characters()
    log.debug(characters)

    for char_name in characters:
        var character_data = save.load_character(char_name)
        if not character_data.has("name"):
            log.warn("Character data missing name", character_data)
            continue
        var new_button: CharacterInfoTemplate
        new_button = character_info_template.instantiate()
        character_buttons.append(new_button)
        new_button.set_character_data(character_data)
        %CharacterContainer.add_child.call_deferred(new_button)


func _connect_signals() -> void:
    var create_button: Button = %CreateCharacter
    create_button.pressed.connect(_on_create_pressed)
    var delete_button: Button = %DeleteCharacter
    delete_button.pressed.connect(_on_delete_pressed)
    var load_button: Button = %LoadWorld
    load_button.pressed.connect(_on_load_pressed)
    signals.selected_character.connect(_on_selected_character)
    signals.connected_to_server.connect(_on_connected_to_server)


func _on_create_pressed() -> void:
    Globals.views.spawn(CreateCharacterView)
    despawn()


func _on_delete_pressed() -> void:
    if not current_character.has("name"):
        log.warning("Selected character, but not name was found.")
        return

    save.delete_character(current_character.name)
    populate_character_list()


func _on_load_pressed() -> void:
    if not current_character:
        log.warn("Cannot enter world without selecting a character!")
        return

    log.info("Entering world as " + current_character.get("name"))


func _on_selected_character(character_data: Dictionary) -> void:
    current_character = character_data
    log.info("Selected character: " + str(current_character))


func _on_connected_to_server() -> void:
    despawn()


func _ready() -> void:
    _connect_signals()
    populate_character_list()
