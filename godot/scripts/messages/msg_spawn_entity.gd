class_name MsgSpawnEntity extends Msg

var resource_path := ""
var entity_data := {}
var authority := 1
var id := -1
var display_name := "{ DISPLAY_NAME }"
var position := Vector3(0, 0, 0)


func serialize() -> Dictionary:
    return {
        "type": Type.SPAWN_ENTITY,
        "payload": {
            "resource_path": resource_path,
            "entity_data": entity_data,
            "authority" : authority,
            "id": id,
            "display_name": display_name,
            "position": position
        }
    }


func deserialize(payload: Dictionary):
    resource_path = payload.resource_path
    entity_data = payload.entity_data
    authority = payload.authority
    id = payload.id
    display_name = payload.display_name
