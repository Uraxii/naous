class_name Equipment extends Resource

enum EQUIP_ENUM {MASK}
var EQUIP_MAP := {
    EQUIP_ENUM.MASK: MaskItem,
}

@export var mask: MaskItem

@export var weapon_right: WeaponItem
@export var weapon_left: WeaponItem

@export var torso: Item
@export var legs: Item
@export var shoulders: Item

@export var echoes: Array[EchoItem]


func _init() -> void:
    if echoes == null:
        echoes = []
