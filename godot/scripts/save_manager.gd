class_name SaveManager extends Node

const CHARACTER_DIR = "user://"
const CHARACTER_FILE_EXTENSION = "_data.json"

@onready var logger := Globals.logger

var current_character


func get_character_file_path(character_name: String) -> String:
    return  CHARACTER_DIR + character_name + CHARACTER_FILE_EXTENSION


func get_all_characters() -> Array[String]:
    var character_list: Array[String] = []
    var dir = DirAccess.open(CHARACTER_DIR)

    if not dir:
        push_error("Could not open character directory: " + CHARACTER_DIR)
        return character_list

    dir.list_dir_begin()
    var file_name = dir.get_next()

    while file_name != "":
        if file_name.ends_with(CHARACTER_FILE_EXTENSION):
            var character_name = file_name.trim_suffix(CHARACTER_FILE_EXTENSION)
            character_list.append(character_name)

        file_name = dir.get_next()

    dir.list_dir_end()

    return character_list


func load_character(character_name: String) -> Dictionary:
    var character_path = get_character_file_path(character_name)

    var file = FileAccess.open(character_path, FileAccess.READ)
    if not FileAccess.file_exists(character_path):
        logger.error("Character file for %s does not exist!" % character_name)
        return {}

    var json_object = JSON.new()
    
    if json_object.parse(file.get_as_text()) != OK:
        var err_msg = "Failed to parse character file!"
        var err_reason = json_object.get_error_message()
        var err_line = json_object.get_error_line()
        logger.error("%s\n\tMessage: %s,\n\tLine: %s" % [
            err_msg, err_reason, err_line])
        return {}

    var character_data = json_object.data
    if not "name" in character_data:
        character_data["name"] = character_name
        push_warning("Player save didn't contain its name! Initiating a new Character")
    else:
        character_name = character_data["name"]

    return character_data


func save_character(data: EntityData) -> bool:
    """
    Returns true on success, false on failure.
    """

    var err_msg = "Unable to save character!"
    var character_name = data.id.display_name
    var character_path = get_character_file_path(character_name)

    var file = FileAccess.open(character_path, FileAccess.WRITE)
    var err = FileAccess.get_open_error()
    err = FileAccess.get_open_error()
    # File not found error
    if err:
        var err_reason = error_string(FileAccess.get_open_error())
        logger.error("ERROR: %s, REASON: %s" % [err_msg, err_reason])
        return false

    if not file.store_string(JSON.stringify(data.serialize(), "\t")):
        var err_reason = FileAccess.get_open_error()
        logger.error("ERROR: %s, REASON: %s" % [err_msg, err_reason])

    return false


func delete_character(character_name: String):
    var character_file_path = get_character_file_path(character_name)
    var error_code = DirAccess.remove_absolute(character_file_path)
    if error_code:
        logger.warn("Error deleting file! Error code: ", error_code)
