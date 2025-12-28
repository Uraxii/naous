class_name MsgActorData extends Msg

var actor_data: ComponentData


func get_id() -> BFT.ID:
    return BFT.ID.MSG_ACTOR_DATA


func serialize() -> Dictionary:
    return {
        "actor_data": actor_data.serialize() if actor_data else {  }
    }


func deserialize(payload: Dictionary) -> MsgActorData:
    var actor_data_dict = payload.get("actor_data", {  })
    actor_data = ComponentData.new().deserialize(actor_data_dict)
    return self

