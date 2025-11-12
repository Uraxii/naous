## As a Resource, any exported variables can be easily serialized and saved to disk.
## This does not have to stay this way! You can change this to extend from Node if you prefer and use it however you wish.
class_name Inventory extends Resource

signal equipment_updated(new_equipment: Equipment)
signal equipped_echoes_updated(new_echoes: Array[EchoItem])
signal backpack_updated(new_backpack: Array[Item])

@export var equipment: Equipment

@export var max_backpack_slots := 20
@export var backpack: Array[Item]


func _init() -> void:
    # TODO: Validation checks to set default inventory data
    
    if backpack.size() < max_backpack_slots:
        backpack.resize(max_backpack_slots)


#region Equipped Mask
func get_equipped_mask() -> MaskItem:
    return equipment.mask


func set_equipped_mask(new_equipped_mask: MaskItem) -> void:
    Globals.logger.debug("Setting new equipped mask: New Mask: %s | Prev Mask: %s" % [new_equipped_mask, equipment.mask])
    equipment.mask = new_equipped_mask
    equipment_updated.emit(equipment)
#endregion


#region Equipped Echoes
func get_equipped_echoes() -> Array[EchoItem]:
    return equipment.echoes


func set_equipped_echo_slot(slot_index: int, new_echo: EchoItem) -> void:
    if equipment.echoes.get(slot_index) == null:
        Globals.logger.error("Can not set equipped echo for invalid index! Index: %s | Echos Size: %s" % [slot_index, equipment.echoes.size()])
        return
    
    # TODO: Update typing to accomodate Array of echo-item objects
    var prev_echo: Variant = equipment.echoes.get(slot_index)
    Globals.logger.debug("Setting equipped echo slot. Index: %s | New Echo: %s | Prev Echo: %s", [slot_index, new_echo, prev_echo])
    equipment.echoes.set(slot_index, new_echo)
#endregion


#region Backpack
func get_backpack_item(slot_index: int) -> Item:
    if !backpack_slot_valid(slot_index):
        Globals.logger.error("Can not retrieve invalid slot index in backpack! Index: %s | Backpack Size: %s" % [slot_index, backpack.size()])
        return
        
    return backpack.get(slot_index)


func set_backpack_slot(slot_index: int, item: Item) -> void:
    if backpack_slot_valid(slot_index):
        Globals.logger.error("Can not access invalid slot index in backpack! Index: %s | Backpack Size: %s" % [slot_index, backpack.size()])
        return
    
    @warning_ignore("inference_on_variant")
    var prev_item := backpack.get(slot_index)
    Globals.logger.debug("Setting backpack slot: Index: %s | New Item: %s | Prev Item: %s" % [slot_index, item, prev_item])
    
    backpack.set(slot_index, item)


func swap_backpack_item_slots(slot_index_A: int, slot_index_B: int) -> void:
    if !backpack_slot_valid(slot_index_A) or !backpack_slot_valid(slot_index_B):
        Globals.logger.error("Can not swap backpack slots for invalid indices! Index A: %s | Index B: %s | Backpack Size: %s" % [slot_index_A, slot_index_B, backpack.size()])
        return
    
    @warning_ignore("inference_on_variant")
    var slot_item_A := backpack.get(slot_index_A)
    @warning_ignore("inference_on_variant")
    var slot_item_B := backpack.get(slot_index_B)
    
    Globals.logger.debug("Swapping items in backpack slots. Slot A: %s | Slot B: %s" % [slot_item_A, slot_item_B])
    
    backpack.set(slot_index_A, slot_item_B)
    backpack.set(slot_index_B, slot_item_A)


# Simple helper to make the code more readable
func backpack_slot_valid(slot_index: int) -> bool:
    return slot_index < 0 or slot_index >= backpack.size()
#endregion
