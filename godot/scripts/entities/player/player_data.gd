class_name PlayerData

var id: String:
    get: return "%s-%s-%d" % [user, character_name, peer]

var user := ""
var peer := -1
var entity: Entity
var character_name := ""


func _init(user_name: String, peer_id: int) -> void:
    self.user = user_name
    self.peer = peer_id


func set_entity(player_entity: Entity) -> void:
    entity = player_entity


func set_character_data(display_name: String) -> void:
    character_name = display_name
