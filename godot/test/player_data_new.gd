class_name ComponentData extends Resource

## Actor's UUID while playing. Set by the server when spawned.
var id: int
## Peer that has authority over this actor. Set by the server.
var peer_auth_id: int

var info:       ActorInfoData = ActorInfoData.new()
var stats:      StatsData
var spellbook:  SpellbookData


func serialize() -> Dictionary:
    var dict := {
        "id": id,
        "peer_auth_id": peer_auth_id,
    }

    if info:
        dict[ComponentActorInfo.ID] = info.serialize()
    if stats:
        dict[ComponentStatManager.ID] = stats.serialize()
    if spellbook:
        dict[ComponentSpellbook.ID] = spellbook.serialize()

    return dict


func deserialize(data: Dictionary) -> ComponentData:
    id = data.get("id", Actor.INVALID_ID)
    peer_auth_id = data.get("peer_auth_id", NaousNet.SERVER_PEER_ID)

    var info_data = data.get(ComponentActorInfo.ID)
    if info_data:
        info.deserialize(info_data)

    var stats_data = data.get(ComponentStatManager.ID)
    if stats_data:
        stats = StatsData.new().deserialize(stats_data)

    var spellbook_data = data.get(ComponentSpellbook.ID)
    if spellbook_data:
        spellbook = SpellbookData.new().deserialize(spellbook_data)

    return self
