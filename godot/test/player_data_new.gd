class_name ComponentData extends Resource

var info:       ActorInfoData = ActorInfoData.new()
var stats:      StatsData
var spellbook:  SpellbookData


func serialize() -> Dictionary:
    var dict := {  }

    if info:
        dict[ComponentActorInfo.ID] = info.serialize()
    if stats:
        dict[ComponentStatManager.ID] = stats.serialize()
    if spellbook:
        dict[ComponentSpellbook.ID] = spellbook.serialize()


    return {
        "info":         info.serialize(),
        "stats":        stats.serialize(),
        "spellbook":    spellbook.serialize(),
    }


func deserialize(data: Dictionary) -> ComponentData:
    var info_data = data.get(ComponentActorInfo.ID)
    if info_data:
        info.deserialize(info_data)

    var stats_data = data.get(ComponentStatManager.ID)
    if stats_data:
        stats.deserialize(stats_data)

    var spellbook_data = data.get(ComponentSpellbook.ID)
    if spellbook_data:
        spellbook.deserialize(spellbook_data)

    return self
