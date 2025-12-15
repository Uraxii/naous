class_name IconManager

const ICON_DIR := "res://assets/icons/"
const ICON_EXT := ".png"

static var default_icon := find("sword")
static var cache: Dictionary[String, Texture2D] = {  }


static func find(id: String) -> Texture2D:
    var icon = cache.get(id)
    if icon:
        return icon

    if not Sanitizer.is_legal(id):
        push_warning("Received icon id with illegal characters!")
        return default_icon

    var icon_path = ICON_DIR + id + ICON_EXT
    icon = load(icon_path)
    if not icon or icon is not Texture2D:
        push_warning("Failed to find icon at %s" % icon_path)
        icon = default_icon

    cache[id] = icon
    return icon


static func path_to_id(file_path: String) -> String:
    return file_path.get_file().trim_suffix(ICON_EXT)
