class_name StatusEffect extends Node

var data: StatusData
var target: Entity
var source: Entity
var stacks := 0

var expiration_timer := Timer.new()
var tick_timer := Timer.new()


static func node_name_for(status_id: String) -> String:
    var cleaned := status_id.strip_edges()
    if cleaned.is_empty():
        cleaned = "status"
    cleaned = cleaned.replace("/", "_").replace(":", "_").replace(" ", "_")
    return "StatusEffect_%s" % cleaned


func setup(status_data: StatusData, target_entity: Entity, source_entity: Entity) -> void:
    data = status_data
    target = target_entity
    source = source_entity

    expiration_timer.one_shot = true
    expiration_timer.timeout.connect(_on_expired)
    add_child(expiration_timer)

    tick_timer.one_shot = false
    tick_timer.timeout.connect(_on_tick)
    add_child(tick_timer)

    add_stack(source_entity)
    _start_ticking()


func add_stack(source_entity: Entity) -> void:
    if is_instance_valid(source_entity):
        source = source_entity

    var stack_limit := max(1, data.max_stacks)
    stacks = min(stacks + 1, stack_limit)
    _refresh_expiration()


func _start_ticking() -> void:
    if data == null or data.tick_rate <= 0.0:
        return

    tick_timer.wait_time = data.tick_rate
    tick_timer.start()


func _refresh_expiration() -> void:
    if data == null or data.expiration_time <= 0.0:
        expiration_timer.stop()
        return

    expiration_timer.wait_time = data.expiration_time
    expiration_timer.start()


func _on_tick() -> void:
    if not _has_valid_context():
        queue_free()
        return

    for _stack_index in range(stacks):
        _cast_status_spell()


func _cast_status_spell() -> void:
    if data.spell == null:
        return

    var status_spell := Spell.new()
    status_spell.setup(data.spell, source if is_instance_valid(source) else target)
    status_spell.target_override = target

    for trait_data in data.spell.traits:
        if not trait_data:
            continue

        var trait_script := trait_data.trait_script
        if not trait_script:
            continue

        var trait: Trait = trait_script.new()
        trait.setup(trait_data, status_spell)
        add_child(trait)
        trait.cast()
        trait.queue_free()

    status_spell.free()


func _has_valid_context() -> bool:
    return data != null and is_instance_valid(target)


func _on_expired() -> void:
    queue_free()
