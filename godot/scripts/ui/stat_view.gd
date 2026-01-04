class_name StatView extends View

@export var stat_id := ComponentStat.HEALTH_ID
@export var label: Label

var stat: ComponentStat


func set_entity(new_entity: Entity) -> void:
    if stat and stat.change.is_connected(_on_change):
        stat.change.disconnect(_on_change)

    stat = new_entity.stats.find(stat_id)
    stat.change.connect(_on_change)
    _on_change(stat.current, stat.current)


func _on_change(new: float, _old: float) -> void:
    label.text = str(new)


func _setup() -> void:
    set_entity(get_parent() as Entity)


func _ready() -> void:
    if not label:
        label = Label.new()
        add_child(label)

    _setup.call_deferred()
