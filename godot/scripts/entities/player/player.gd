class_name Player extends Entity

@onready var is_client: bool = transform_sync.is_multiplayer_authority()

var character_data: Dictionary
var active_character: String = ""


func _ready() -> void:
    super._ready()
    if is_client:
        %StatView.visible = true
        load_character_from_disk(active_character)
    Globals.signal_bus.save_game.connect(save_active_character_to_disk)

func data_path_for_character(character_name: String):
    #!Note: custom folders won't work
    return "user://" + str(id) + "_" + character_name + "_character_data.json"

func save_active_character_to_disk() -> void:
    if is_client: # Save data locally for the player
        var character_path = data_path_for_character(active_character)
        var file = FileAccess.open(character_path, FileAccess.WRITE)
        if file:
            file.store_string(JSON.stringify(character_data, "\t"))
        else:
            push_warning("Couldn't write to player save file!")
            print("file error: ", FileAccess.get_open_error())

func load_character_from_disk(character_name: String) -> void:
    var character_path = data_path_for_character(character_name)
    var file = FileAccess.open(character_path, FileAccess.READ)
    if file and FileAccess.file_exists(character_path):
        var json_object = JSON.new()
        json_object.parse(file.get_as_text())
        character_data = json_object.data
        if not "name" in character_data:
            character_data["name"] = character_name
            push_warning("Player save didn't contain its name! Initiating a new Character")
        else:
            character_name = character_data["name"]
    else:
        push_warning("Player save doesn't exist, initializing a new one")
        character_data = {}
        character_data["name"] = character_name
        save_active_character_to_disk()
