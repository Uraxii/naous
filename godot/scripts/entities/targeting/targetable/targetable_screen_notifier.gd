class_name TargetableScreenNotifier extends VisibleOnScreenNotifier3D

@onready var signals := Globals.signal_bus

var entity: Entity:
    set = set_entity
var targetable: Targetable


func target_entered_screen() -> void:
    #print("Target entered screen! - ", targetable.get_parent().get_parent().name)
    signals.target_entered_screen.emit(targetable)


func target_exited_screen() -> void:
    #print("Target exited screen! - ", targetable.get_parent().get_parent().name)
    signals.target_exited_screen.emit(targetable)


func match_aabb_to_entity(aabb_entity: Entity) -> void:
    if aabb_entity.name == "RubbleEntity":
        var xyz := true
    var new_aabb := aabb_entity.get_local_aabb()
    aabb = new_aabb


func set_entity(new_entity: Entity) -> void:
    entity = new_entity
    match_aabb_to_entity(entity)


#region Godot Callbacks
func _ready() -> void:
    screen_entered.connect(target_entered_screen)
    screen_exited.connect(target_exited_screen)
    
    if get_parent() is Entity:
        set_entity.call_deferred(get_parent())
#endregion
