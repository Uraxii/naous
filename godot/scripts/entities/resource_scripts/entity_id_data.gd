class_name EntityIdData extends Resource

@export var display_name    := "No Name"
@export var title           := ""


func serialize() -> Dictionary:
    return {
        "display_name": display_name,
        "title":        title,
    }


func deserialize(data: Dictionary) -> void:
    display_name    = data.get("display_name", display_name)
    title           = data.get("title", title)
