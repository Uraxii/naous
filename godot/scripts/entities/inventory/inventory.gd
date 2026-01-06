## As a Resource, any exported variables can be easily serialized and saved to disk.
## This does not have to stay this way! You can change this to extend from Node if you prefer and use it however you wish.
class_name Inventory extends Resource

signal equipment_updated(new_equipment: Equipment)
signal equipped_echoes_updated(new_echoes: Array[EchoItem])
signal backpack_updated(new_backpack: Array[Item])

@export var equipment: Equipment

@export var max_backpack_slots := 16
@export var backpack: Array[Item]


func _init() -> void:
    # TODO: Validation checks to set default inventory data
    if equipment == null:
        equipment = Equipment.new()
    
    if backpack.size() < max_backpack_slots:
        backpack.resize(max_backpack_slots)

#region EQUIPMENT
#region Equipped Mask
func get_equipped_mask() -> MaskItem:
    return equipment.mask


func set_equipped_mask(new_equipped_mask: MaskItem) -> void:
    if equipment.mask != new_equipped_mask:
        Globals.logger.debug("Setting new equipped mask: New Mask: %s | Prev Mask: %s" % [new_equipped_mask, equipment.mask])
        equipment.mask = new_equipped_mask
        equipment_updated.emit(equipment)
#endregion Equipped Mask


#region Equipped Weapons
func set_equipped_weapon_left(new_weapon: WeaponItem) -> void:
    if equipment.weapon_left != new_weapon:
        equipment.weapon_left = new_weapon
        equipment_updated.emit(equipment)


func get_equipped_weapon_left() -> WeaponItem:
    return equipment.weapon_left


func set_equipped_weapon_right(new_weapon: WeaponItem) -> void:
    if equipment.weapon_right != new_weapon:
        equipment.weapon_right = new_weapon
        equipment_updated.emit(equipment)


func get_equipped_weapon_right() -> WeaponItem:
    return equipment.weapon_right
#endregion Equipped Weapons


#region Set Armor
func set_equipped_torso(new_torso: TorsoItem) -> void:
    if equipment.torso != new_torso:
        equipment.torso = new_torso
        equipment_updated.emit(equipment)


func get_equipped_torso() -> TorsoItem:
    return equipment.torso


func set_equipped_shoulders(new_shoulders: ShoulderItem) -> void:
    if equipment.shoulders != new_shoulders:
        equipment.shoulders = new_shoulders
        equipment_updated.emit(equipment)


func get_equipped_shoulders() -> ShoulderItem:
    return equipment.shoulders


func set_equipped_legs(new_legs: LegsItem) -> void:
    if equipment.legs != new_legs:
        equipment.legs = new_legs
        equipment_updated.emit(equipment)


func get_equipped_legs() -> LegsItem:
    return equipment.legs
#endregion Set Armor

#region Equipped Echoes
func get_equipped_echoes() -> Array[EchoItem]:
    return equipment.echoes


func set_equipped_echo_slot(new_echo: EchoItem, slot_index: int) -> void:
    if slot_index < 0 or slot_index >= equipment.echoes.size():
        Globals.logger.error("Can not set equipped echo for invalid index! Index: %s | Echos Size: %s" % [slot_index, equipment.echoes.size()])
        return
    
    # TODO: Update typing to accomodate Array of echo-item objects
    var prev_echo: Variant = equipment.echoes.get(slot_index)
    
    if prev_echo != new_echo:
        Globals.logger.debug("Setting equipped echo slot. Index: %s | New Echo: %s | Prev Echo: %s", [slot_index, new_echo, prev_echo])
        equipment.echoes.set(slot_index, new_echo)
        equipped_echoes_updated.emit(equipment.echoes)
#endregion Equipped Echoes

#endregion EQUIPMENT


#region Backpack
func get_backpack_item(slot_index: int) -> Item:
    if !backpack_slot_valid(slot_index):
        Globals.logger.error("Can not retrieve invalid slot index in backpack! Index: %s | Backpack Size: %s" % [slot_index, backpack.size()])
        return
        
    return backpack.get(slot_index)


func set_backpack_slot(item: Item, slot_index: int) -> void:
    if backpack_slot_valid(slot_index):
        Globals.logger.error("Can not access invalid slot index in backpack! Index: %s | Backpack Size: %s" % [slot_index, backpack.size()])
        return
    
    @warning_ignore("inference_on_variant")
    var prev_item := backpack.get(slot_index)
    
    if prev_item != item:
        Globals.logger.debug("Setting backpack slot: Index: %s | New Item: %s | Prev Item: %s" % [slot_index, item, prev_item])
        backpack.set(slot_index, item)
        backpack_updated.emit(backpack)


func add_to_backpack(item: Item) -> void:
    var empty_index := find_empty_backpack_slot()
    if empty_index >= 0:
        set_backpack_slot(item, empty_index)


func find_empty_backpack_slot() -> int:
    for i in range(0, backpack.size()):
        if backpack[i] == null:
            return i
    return -1


func swap_backpack_item_slots(slot_index_A: int, slot_index_B: int) -> void:
    if !backpack_slot_valid(slot_index_A) or !backpack_slot_valid(slot_index_B):
        Globals.logger.error("Can not swap backpack slots for invalid indices! Index A: %s | Index B: %s | Backpack Size: %s" % [slot_index_A, slot_index_B, backpack.size()])
        return
    
    @warning_ignore("inference_on_variant")
    var slot_item_A := backpack.get(slot_index_A)
    @warning_ignore("inference_on_variant")
    var slot_item_B := backpack.get(slot_index_B)
    
    Globals.logger.debug("Swapping items in backpack slots. Slot A: %s | Slot B: %s" % [slot_item_A, slot_item_B])
    
    set_backpack_slot(slot_item_B, slot_index_A)
    set_backpack_slot(slot_item_A, slot_index_B)


# Simple helper to make the code more readable
func backpack_slot_valid(slot_index: int) -> bool:
    return slot_index < 0 or slot_index >= backpack.size()
#endregion

#region Serialization Logic
func serialize() -> Dictionary:
    push_warning("Inventory serialization not implemented.")
    return {}


func deserialize(data: Dictionary) -> void:
    push_warning("Inventory deserialization not implemented.")
#endregion
