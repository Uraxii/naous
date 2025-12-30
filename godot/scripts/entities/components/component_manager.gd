class_name ComponentManager extends Node

const ID := "Components"

var setup_funcs: Dictionary[String, Callable] = {
    ComponentMove.ID: setup_move,
    ComponentSpellbook.ID: setup_spellbook,
    ComponentStatManager.ID: setup_stats,
}

@export var entity: Entity:
    set = set_entity

@onready var comp_cache: Dictionary[String, Node] = get_all()


func get_stat(stat_id: String) -> float:
    var stats: ComponentStatManager = find(ComponentStatManager.ID)
    return stats.get_value(stat_id)


func set_data(component_type: String, data_dict: Dictionary) -> void:
    var comp = find(component_type)
    if comp and comp.has_method("set_data"):
        comp.set_data(data_dict)


func set_entity(new_entity: Entity) -> void:
    entity = new_entity
    entity.change_data.connect(_on_entity_data_change)


func get_all() -> Dictionary[String, Node]:
    var children = get_children()
    for child in children:
        _on_component_added(child)
    return comp_cache


func find(node_name: String) -> Node:
    var comp = comp_cache.get(node_name)

    if not comp:
        comp = find_child(node_name)
        if comp:
            comp_cache[comp.name] = comp

    return comp

#region Component Setup
func setup_move(move_comp: ComponentMove) -> void:
    var anim_comp: ComponentAnimator = find(ComponentAnimator.ID)
    if anim_comp and not move_comp.moving.is_connected(anim_comp.moving):
        move_comp.moving.connect(anim_comp.moving)

    var stats_man_comp: ComponentStatManager = find(
        ComponentStatManager.ID)

    if stats_man_comp:
        var stat_comp_signals: Dictionary[String, Callable] = {
            ComponentStat.SPEED_ID: move_comp.on_speed_change,
            ComponentStat.JUMP_FORCE_ID: move_comp.on_jump_force_change,
            ComponentStat.GRAVITY_ID: move_comp.on_gravity_change,
        }

        for stat_id in stat_comp_signals.keys():
            var comp: ComponentStat = stats_man_comp.find(stat_id)

            if not comp:
                continue

            var signal_handler := stat_comp_signals[stat_id]
            # This initializes the value
            signal_handler.call(comp.current, comp.current)
            if not comp.change.is_connected(signal_handler):
                comp.change.connect(signal_handler)


func setup_spellbook(spellbook_comp: ComponentSpellbook) -> void:
    if entity.data.spellbook:
        spellbook_comp.setup(entity, entity.data.spellbook)


func setup_stats(stats_comp: ComponentStatManager) -> void:
    if entity.data.stats:
        stats_comp.setup(entity.data.stats)
#endregion

#region Signal Handler
func connect_signals() -> void:
    child_entered_tree.connect(_on_component_added)
    child_exiting_tree.connect(_on_component_removed)


func _on_component_added(node: Node) -> void:
    comp_cache.set(node.name, node)


func _on_component_removed(node: Node) -> void:
    comp_cache.erase(node.name)


func _on_entity_data_change(data: EntityData) -> void:
    for comp in comp_cache.values():
            if setup_funcs.has(comp.name):
                var setup_callable: Callable = setup_funcs.get(comp.name)
                setup_callable.call(comp)
#endregion

#region Godot Callback Functions
func _ready() -> void:
    connect_signals()

    if not entity:
        entity = get_parent()
#endregion


## Gathers data from all child components that support serialization.
func serialize() -> Dictionary:
    var full_state := {}

    # 1. Serialize Entity-Level Data (formerly in ComponentData)
    # Assuming the Entity holds the authoritative ID and Peer ID now.
    if entity:
        full_state["id"] = entity.get("id") 
        full_state["peer_auth_id"] = entity.get("peer_auth_id")

    # 2. Serialize Components
    # We iterate over all cached components.
    for comp_name in comp_cache:
        var comp = comp_cache[comp_name]

        # Duck Typing: If the component knows how to save itself, let it.
        if comp.has_method("serialize"):
            var comp_data = comp.serialize()

            # Only save if data was actually returned (optional optimization)
            if comp_data != null and not comp_data.is_empty():
                full_state[comp_name] = comp_data

    return full_state


## Distributes data to matching components.
func deserialize(data: Dictionary) -> void:
    # 1. Deserialize Entity-Level Data
    if entity:
        if "id" in data: 
            entity.set("id", data["id"])
        if "peer_auth_id" in data: 
            entity.set("peer_auth_id", data["peer_auth_id"])

    # 2. Deserialize Components
    # We iterate through the keys in the data dictionary.
    for key in data.keys():
        # Skip root-level keys that aren't components
        if key in ["id", "peer_auth_id"]:
            continue

        # Attempt to find a component matching this key
        var comp = find(key)

        # If the component exists and accepts data, pass it in.
        if comp:
            if comp.has_method("deserialize"):
                comp.deserialize(data[key])
            elif comp.has_method("set_data"):
                # Fallback to your existing set_data method if preferred
                comp.set_data(data[key])
        else:
            push_warning("ComponentManager: Data found for '%s', but no component exists." % key)
