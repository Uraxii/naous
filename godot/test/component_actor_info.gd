class_name ComponentActorInfo extends Node

const ID := "ActorInfo"

var data := ActorInfoData.new()

var display_name: String:
    get: return data.display_name
    set(value): data.display_name = value


var title: String:
    get: return data.title
    set(value): data.title = value


func set_data(new_data: ActorInfoData) -> void:
    data = new_data

