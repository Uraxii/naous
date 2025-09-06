class_name EntitySpawn extends MultiplayerSpawner

@export var player_scene: PackedScene = preload("uid://bmpfv2bwc6v1r")


func _ready():
    spawn_function = Callable(self, "_spawn_custom")


func _spawn_custom(data):
    var entity = player_scene.instantiate()
    entity.set_multiplayer_authority(data.authority)
    entity.name = data.id
    return entity
