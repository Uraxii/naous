class_name TargetPanel extends PanelContainer

@onready var target_name_label: Label = %TargetNameLabel
@onready var target_resource_bar: ProgressBar = %TargetResourceBar

var tracked_entity: Entity
var tracked_stat: ComponentStat


## Percent should be a float from 0.0 to 1.0
func set_resource_percentage(percent: float) -> void:
    target_resource_bar.value = percent * 100.0


func set_target_name(target_name: String) -> void:
    target_name_label.text = target_name


func track_entity(entity: Entity, stat_c: ComponentStat) -> void:
    Globals.logger.debug("Tracking entity: %s" % [entity.name])
    tracked_entity = entity
    set_target_name(tracked_entity.name)
    if is_instance_valid(stat_c):
        Globals.logger.debug("> Tracking entity stat: %s" % [stat_c.name])
        tracked_stat = stat_c
        set_resource_percentage(tracked_stat.current / tracked_stat.max_value)
        tracked_stat.change.connect(_on_entity_resource_change)
        target_resource_bar.show()
    else:
        target_resource_bar.hide()


func untrack_current_objects() -> void:
    print("Untracking current target objects")
    tracked_entity = null
    if is_instance_valid(tracked_stat):
        tracked_stat.change.disconnect(_on_entity_resource_change)
        if tracked_stat.change.is_connected(_on_entity_resource_change):
            tracked_stat.change.disconnect(_on_entity_resource_change)
        tracked_stat = null


func _on_entity_resource_change(new: float, old: float) -> void:
     # This can hit errors if the target was untracked and had its stat change on the same frame (eg. if an enemy is defeated and its health reaches 0)
    # This check ensures the hud piece doesn't blow up
    if is_instance_valid(tracked_stat):
        set_resource_percentage(new / tracked_stat.max_value)
