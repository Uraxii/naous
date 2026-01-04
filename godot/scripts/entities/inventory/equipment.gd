class_name Equipment extends Resource

enum EQUIP_ENUM {ANY, MASK, WEAPON, ECHO}
var EQUIP_MAP := {
    EQUIP_ENUM.ANY: Item,
    EQUIP_ENUM.MASK: MaskItem,
    EQUIP_ENUM.WEAPON: WeaponItem,
    EQUIP_ENUM.ECHO: EchoItem,
}

@export var mask: MaskItem

@export var weapon_right: WeaponItem
@export var weapon_left: WeaponItem

@export var torso: TorsoItem
@export var legs: LegsItem
@export var shoulders: ShoulderItem

const MAX_ECHOES := 4
@export var echoes: Array[EchoItem]


func _init() -> void:
    if echoes.size() < MAX_ECHOES:
        echoes.resize(MAX_ECHOES)
