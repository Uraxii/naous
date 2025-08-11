class_name ViewManager extends CanvasLayer

@onready var signals := Globals.signal_bus

var active_views: Array[View] = []

# TODO: Find some way to not have to maintain this data.
var _scene_map: Dictionary[GDScript, PackedScene] = {
    CharacterSelectView: preload("res://scenes/ui/character_select_view.tscn"),
    CreateCharacterView: preload("res://scenes/ui/create_character_view.tscn"),
    LoginView: preload("res://scenes/ui/login_view.tscn"),
    MainView: preload("res://scenes/ui/main_view.tscn"),
    ConsoleView: preload("res://scenes/ui/console_view.tscn"),
    SystemView: preload("res://scenes/ui/system_view.tscn"),
}

var is_ui_visible := true


func spawn(type: GDScript, do_not_register=false) -> View:
    var view_scene = _scene_map.get(type)
    
    if not view_scene:
        printerr("Did not find scene for ", type, " view!")
        return null
        
    var view_node := view_scene.instantiate() as View
    
    if not view_node:
        printerr("Failed to instantiate node for ", type, " view.")
        return null
    
    if not do_not_register:
        active_views.append(view_node)
        
    add_child(view_node)
    view_node.initalize()
    signals.spawn_view.emit(view_node)
    view_node.visible = is_ui_visible
    
    return view_node


func despawn_all() -> void:
    for view in active_views:
        if view:
            view.despawn()


func _ready():
    signals.ui_toggle.connect(_on_ui_toggle)


func _on_ui_toggle():
    is_ui_visible = not is_ui_visible
    
    for view in active_views:
        view.visible = is_ui_visible


func _on_despawn_view(view: View) -> void:
    active_views.erase(view)
