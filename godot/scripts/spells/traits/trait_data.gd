class_name TraitData extends Resource

@export var trait_type := BFT.ID.TRAIT_DAMAGE_TARGET
@export var draw := 1.0
@export_category("Modify Stats")
@export var damage  := 0.0
@export var healing := 0.0
@export_category("Projectile")
@export var projectile_scene: PackedScene
@export_category("Spawning")
@export var summon_entity:  PackedScene
@export var entity_data:    EntityData
@export_category("Apply Effects")
@export var apply_status: SpellData

var trait_script: GDScript = Trait:
    get: return BFT.get_type(trait_type)


func serialize() -> Dictionary:
    var data := {}

    data["type"] = trait_type
    data["draw"] = draw
    data["damage"] = damage
    data["healing"] = healing
    data["summon_entity"] = summon_entity.resource_path if summon_entity else ""

    if entity_data:
        data["entity_data"] = entity_data.serialize()
    else:
        data["entity_data"] = null

    if apply_status:
        data["apply_status"] = apply_status.serialize()
    else:
        data["apply_status"] = null

    return data


func deserialize(data: Dictionary) -> void:
    draw    = data.get("draw", draw)
    damage  = data.get("damage", damage)
    healing = data.get("healing", healing)

    var type_of_trait: BFT.ID = data.get("type", BFT.ID.UNKNOWN)
    trait_script = BFT.get_type(type_of_trait)
    print_debug("trait script is ", trait_script)

    var scene_path: String = data.get("summon_entity", "")
    if not scene_path.is_empty():
        summon_entity = load(scene_path) as PackedScene
    else:
        summon_entity = null

    var entity_dict = data.get("entity_data")
    if entity_dict and entity_dict is Dictionary:
        if not entity_data:
            entity_data = EntityData.new() 
        entity_data.deserialize(entity_dict)
    elif entity_dict == null:
        entity_data = null

    var status_dict = data.get("apply_status")
    if status_dict and status_dict is Dictionary:
        if not apply_status:
            apply_status = SpellData.new()
        apply_status.deserialize(status_dict)
    elif status_dict == null:
        apply_status = null
