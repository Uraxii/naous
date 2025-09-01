class_name MainView extends View


func _ready() -> void:
    var host: Button = %Host
    host.pressed.connect(_on_host_game)
    
    var join: Button = %Join
    join.pressed.connect(_on_join_game)


func _on_host_game() -> void:
    var cfg: InstanceConfig = load(
        "res://resources/default_instance_config.tres")
    InstanceAPI.start_server(cfg)
    despawn()
    

func _on_join_game() -> void:
    InstanceAPI.start_client()
    despawn()
