class_name MsgSpawnActor extends Msg

var actor_data := ComponentData.new()


func get_id() -> BFT.ID:
    return BFT.ID.MSG_SPAWN_ACTOR

