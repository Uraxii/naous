class_name Actor extends Node

const INVALID_ID := 0

@onready var signals := Globals.signal_bus
@onready var lg := Globals.logger

var iid := INVALID_ID
var peer_auth := NaousNet.SERVER_PEER_ID
var display_name := "No Name"
var title := "The Nameless One"

var stats := {
    BFT.Stat.DEX:           0,
    BFT.Stat.CON:           0,
    BFT.Stat.INT:           0,
    BFT.Stat.STR:           0,
}

var equipment := {
    BFT.EquipSlots.HEAD: "",
    BFT.EquipSlots.NECK: "",
    BFT.EquipSlots.BACK: "",
    BFT.EquipSlots.SHOLDIER: "",
    BFT.EquipSlots.CHEST: "",
    BFT.EquipSlots.BELT: "",
    BFT.EquipSlots.LEGS: "",
    BFT.EquipSlots.RING_1: "",
    BFT.EquipSlots.RING_2: "",
}

var health := 0.0
var health_max: float:
    get: return stats[BFT.Stat.CON] * 100.0

var gravity := 1.0
var speed := 20.0

var spells:     Array = ["fireball"]
var inventory:  Array = []


func serialize() -> Dictionary:
    return {
        "iid": iid,
        "display_name": display_name,
        "title": title,
        "stats": stats,
        "equipment": equipment,
        "spells": spells,
        "inventory": inventory,
    }


func deserialize(dict: Dictionary) -> Actor:
    iid = dict.get("iid", iid)
    display_name = dict.get("display_name", display_name)
    stats = dict.get("stats", stats)
    equipment = dict.get("equipment", equipment)
    spells = dict.get("spells", spells)
    inventory = dict.get("inventory", inventory)
    return self

var comp_container: Node
var components: Dictionary[BFT.ID, Node] = {  }


#region AABB Targeting Helpers
func get_local_aabb() -> AABB:
    var visual_instances := _get_visual_instances()
    var local_transformed_aabb := _get_local_aabb_from_instances(visual_instances)
    return local_transformed_aabb


func get_world_aabb() -> AABB:
    # FIXME: Account for scaling of nodes (need to pass this to Entity)
    var visual_instances := _get_visual_instances()
    var world_transformed_aabb := _get_world_transformed_aabb_from_instances(visual_instances)
    return world_transformed_aabb


func _get_visual_instances() -> Array[VisualInstance3D]:
    var instance_children := find_children("*", "VisualInstance3D")
    var visual_instances: Array[VisualInstance3D] = []
    visual_instances.assign(instance_children)
    return visual_instances


func _get_local_aabb_from_instances(visual_instances: Array[VisualInstance3D]) -> AABB:
    var final_aabb := AABB()

    for visual_instance: VisualInstance3D in visual_instances:
        var instance_aabb := visual_instance.get_aabb()
        if not final_aabb.has_volume():
            final_aabb = instance_aabb
        else:
            final_aabb.merge(instance_aabb)

    return final_aabb


func _get_world_transformed_aabb_from_instances(visual_instances: Array[VisualInstance3D]) -> AABB:
    var final_transformed_aabb := AABB()

    for visual_instance: VisualInstance3D in visual_instances:
        var instance_aabb := visual_instance.get_aabb()
        # MATRIX MATH ORDER MATTERS!
        # For global-space transforms, multiply the global transform BY the local transform (seen here)
        # This converts the local-space AABB transform (which doesn't contain things like scale or rotation) to its transform in global space.
        var world_instance_aabb := visual_instance.global_transform * instance_aabb
        if final_transformed_aabb.position == Vector3.ZERO and final_transformed_aabb.size == Vector3.ZERO:
            final_transformed_aabb = world_instance_aabb
        else:
            final_transformed_aabb.merge(world_instance_aabb)

    return final_transformed_aabb
#endregion



#region Components
func get_comp(kind: BFT.ID) -> Node:
    return components.get(kind)


func set_components(data: ComponentData) -> void:
    for comp in data.get_component_data():
        add_component(comp["kind"], comp["data"])


func setup_anim(anim_comp: ComponentAnimator, data) -> void:
    pass


func setup_info(info_comp: ComponentActorInfo, data: ActorInfoData) -> void:
    pass


func setup_move(move_comp: ComponentMove, data) -> void:
    var anim_comp: ComponentAnimator = get_comp(BFT.ID.COMP_ANIM)
    if anim_comp and not move_comp.moving.is_connected(anim_comp.moving):
        move_comp.moving.connect(anim_comp.moving)

    var stats_comp: ComponentStatManager = get_comp(BFT.ID.COMP_STATS)
    if stats_comp:
        var stat_comp_signals: Dictionary[String, Callable] = {
            ComponentStat.SPEED_ID: move_comp.on_speed_change,
            ComponentStat.JUMP_FORCE_ID: move_comp.on_jump_force_change,
            ComponentStat.GRAVITY_ID: move_comp.on_gravity_change,
        }

        for stat_id in stat_comp_signals.keys():
            var stat: ComponentStat = stats_comp.find(stat_id)

            if not stat:
                continue

            var signal_handler := stat_comp_signals[stat_id]
            # This initializes the value
            signal_handler.call(stat.current, stat.current)
            if not stat.change.is_connected(signal_handler):
                stat.change.connect(signal_handler)


func setup_spellbook(
    spellbook_comp: ComponentSpellbook,
    data: SpellbookData
) -> void:
    pass


func setup_stats(stats_comp: ComponentStatManager, data: StatsData) -> void:
    pass


func add_component(kind: BFT.ID, data) -> Node:
    var comp = components.get(kind)
    if not comp:
        var script = BFT.get_type(kind)
        if not script:
            lg.error("No script for BFT.ID %d! Ensure the table in bft.gd is up-to-date." % kind)
            return
        comp = script.new()
        components[kind] = comp
        comp_container.add_child.call_deferred(comp)

    var comp_setup_functions: Dictionary[BFT.ID, Callable] = {
        BFT.ID.COMP_ANIM:       setup_anim,
        BFT.ID.COMP_INFO:       setup_info,
        BFT.ID.COMP_MOVE:       setup_move,
        BFT.ID.COMP_SPELLBOOK:  setup_spellbook,
        BFT.ID.COMP_STATS:      setup_stats,
    }

    var setup_func: Callable = comp_setup_functions.get(kind)
    if not setup_func:
        lg.error("No setup func for component %s (%d)" % [
            comp.resource_name, kind])
        return

    setup_func.call(comp, data)
    return comp


func create_component_container() -> void:
    comp_container = Node.new()
    comp_container.name = "Components"
    add_child.call_deferred(comp_container)
#endregion

#region Godot Callback Functions
func _ready() -> void:
    create_component_container()
    add_component(BFT.ID.COMP_TARGETABLE, {})
#endregion-
