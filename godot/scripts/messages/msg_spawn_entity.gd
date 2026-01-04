class_name MsgSpawnEntity extends Msg

var resource_path := ""
var entity_data := {}
var authority := 1
var id := -1
var display_name := "{ DISPLAY_NAME }"
var position := Vector3(0, 0, 0)


func get_id() -> BFT.ID:
    return BFT.ID.MSG_SPAWN_ENTITY
