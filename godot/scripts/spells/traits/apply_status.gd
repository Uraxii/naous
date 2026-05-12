class_name ApplyStatus extends Trait


func cast() -> void:
    if data.apply_status == null:
        return

    var target := spell.target_entity
    if not is_instance_valid(target):
        target = spell.caster

    if not is_instance_valid(target):
        return

    var status_id := data.apply_status.get_status_id()
    var node_name := StatusEffect.node_name_for(status_id)
    var existing := target.get_node_or_null(node_name)

    if existing != null and existing is StatusEffect:
        existing.add_stack(spell.caster)
        return

    var effect := StatusEffect.new()
    effect.name = node_name
    target.add_child(effect)
    effect.setup(data.apply_status, target, spell.caster)
