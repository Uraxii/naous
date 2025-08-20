class_name EntitySynchronizer extends MultiplayerSynchronizer


func sync_stats() -> void:
    var entity: Entity = get_parent()
    if not entity:
        push_warning("EntitySynchronizer could not find entit.")
        return
