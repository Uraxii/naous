extends Control

@onready var entry_point:Control = %EntryPoint
@onready var host_level_select:Control = %HostLevelSelect
@onready var ui_root:Node = $CanvasLayer
@onready var btn_host:Button = %Host
@onready var btn_join:Button = %Join
@onready var txt_max_players:LineEdit = %MaxPlayers
@onready var txt_scene_path:LineEdit = %ScenePath

@onready
var spawner:MultiplayerSpawner = %LevelSpawner

@export
var level_container:Node

@export
var player_controller:PackedScene

const port:int = 7000
const shard_id:String = "1"
const world_scene_dir:String = "res://scenes/world/zones/"

func _ready() -> void:
    API.delegate = MockApiClientImpl.new()
    # Remove default views that get added by singleton for regular main.tscn flow
    Globals.views.despawn_all()

    _populate_spawnable_scenes()

# The "Auto Spawn List" is equivalent to "add_spawnable_scene" for each scene at runtime
# This needs to be called on both client and server to specify the allow list of scenes that can be replicated from server to client
func _populate_spawnable_scenes() -> void:
    var world_scenes:Array[String] = [world_scene_dir]

    while not world_scenes.is_empty():
        var path:String = world_scenes.pop_back()
        if path.ends_with(".tscn"):
            # Scene file
            if OS.is_debug_build():
                print_debug("%s: Found scene: %s" % [name, path])
            spawner.add_spawnable_scene(path)
        # Directory
        elif path.ends_with("/"):
            for resource in ResourceLoader.list_directory(path):
                var sub_path:String = path + resource
                world_scenes.push_back(sub_path)

func _on_host_pressed() -> void:
    entry_point.hide()
    host_level_select.show()

func _on_join_pressed() -> void:
    # TODO: Calling private function to skip hub connection calls
    Globals.game._create_shard_connection("localhost", port, shard_id)
    # TODO: Respond to an rpc to switch to the server's level
    entry_point.hide()

func _on_start_game_pressed() -> void:
    var level:PackedScene = load(txt_scene_path.text)
    if not level or not level.can_instantiate():
        push_error("Invalid level scene: %s" % txt_scene_path.text)
        return

    # "Allow List" for which scenes added to the spawn path root are allowed to replicate
    # Doesn't work when only called on server
    #spawner.add_spawnable_scene(level.resource_path)
    #await get_tree().process_frame

    var shard_config:Dictionary = {
        "shard_id": shard_id,
        "shard_type": "hub",
        "port": port,
        "max_players": int(txt_max_players.text)
        #"manager_host": args.get("manager-host", "localhost"),
        #"manager_port": int(args.get("manager-port", "8081"))
    }

    # Now start the server manager
    var server_manager := ServerManager.new()
    get_tree().root.add_child(server_manager)
    server_manager.initialize_shard(shard_config)

    # TODO: Temporary test logic - need to determine where game scenes should go
    level_container.call_deferred("add_child",_create_level(level))

    ui_root.hide()

func _create_level(level_scene:PackedScene) -> Node:
    var level:Node = level_scene.instantiate()
    # Create player
    var player:Entity = null
    if not player_controller or not player_controller.can_instantiate():
        push_error("%s: player_controller scene not set" % name)
    player = player_controller.instantiate() as Entity
    if player:
        Globals.entities.spawn(player)
        level.add_child(player)

    return level
