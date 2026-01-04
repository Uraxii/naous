class_name SpellData extends Resource

@export var id := ""
@export var hotbar := 1
@export var hotbutton := 1
@export var icon: Texture2D
@export var cooldown_time := 1.0
@export var cast_time := 0.0
@export var traits: Array[TraitData]


func serialize() -> Dictionary:
    var data := {}

    data["id"] = id
    data["hotbar"] = hotbar
    data["hotbutton"] = hotbutton
    data["cast_time"] = cast_time
    data["icon"] = IconManager.path_to_id(icon.resource_path) if icon else ""

    var serialized_traits = []
    for spell_trait in traits:
        serialized_traits.append(spell_trait.serialize())

    data["traits"] = serialized_traits

    return data


func deserialize(data: Dictionary) -> void:
    id = data.get("id", id)
    hotbar = data.get("hotbar", hotbar)
    hotbutton = data.get("hotbutton", hotbutton)
    cast_time = data.get("cast_time", cast_time)
    var icon_name = data.get("icon", "")
    icon = IconManager.find(icon_name)

    var traits_data_array: Array = data.get("traits", [])
    traits.clear()

    for trait_dict in traits_data_array:
        var new_trait = TraitData.new()
        new_trait.deserialize(trait_dict)
        traits.append(new_trait)
