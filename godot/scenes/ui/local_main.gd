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

const port:int = 7000
const shard_id:String = "1"

func _ready() -> void:
	API.delegate = MockApiClientImpl.new()
	# Remove default views that get added by singleton for regular main.tscn flow
	Globals.views.despawn_all()
	
	#FIXME: For some reason we have to add the allow list to server AND client which makes no sense to me
	# But if I just add the scene to the server then the client doesn't get the replicated scene
	# Alternatively can use the "Auto Spawn List" if know at design time all the available maps
	# Will probably need to replicate or get the levels when client connects and then add it at that time 
	# which maybe will come from the shard api
	spawner.add_spawnable_scene("res://scenes/world/zones/devmap.tscn")

func _on_host_pressed() -> void:
	entry_point.hide()
	host_level_select.show()

func _on_join_pressed() -> void:
	# TODO: Calling private function to skip hub connection calls
	Globals.game_man._create_shard_connection("localhost", port, shard_id)
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
	level_container.call_deferred("add_child",level.instantiate())
	#spawner.spawn(level.instantiate())
	
	ui_root.hide()	
