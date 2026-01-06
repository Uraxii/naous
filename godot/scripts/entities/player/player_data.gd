class_name PlayerData

var id: String:
    get: return "%s-%d" % [user, peer]


var user := ""
var peer := -1
var character_name := ""
var entity: Entity


func _init(user_name: String="", peer_id: int=-1) -> void:
    self.user = user_name
    self.peer = peer_id


func set_entity(player_entity: Entity) -> void:
    entity = player_entity
