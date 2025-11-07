## As a Resource, any exported variables can be easily serialized and saved to disk.
## This does not have to stay this way! You can change this to extend from Node if you prefer and use it however you wish.
class_name Inventory extends Resource

signal equipped_mask_updated(new_mask: Variant) # TODO: Update param to mask-item type
signal equipped_echoes_updated(new_echoes: Array[Variant]) # TODO: Update param to echo-item type
signal backpack_updated(new_backpack: Array[Variant]) # TODO: Update param to item type

# TODO: Update this to use item-extended object types, like "Mask" and "Echo"
#  - Probably needs to be a new class type since Dictionary can't have multiple value types
@export var equipped := {
    "mask": "MASK",
    "weapon": "WEAPON",
    "echoes": [
        "ECHO_1",
        "ECHO_2",
        "ECHO_3",
    ]
}

@export var max_backpack_slots := 20
@export var backpack: Array[Item] = [ # TODO: Change type to Array of item object type
    Item.new(),
    Item.new(),
    null,
    Item.new(),
    Item.new(),
]


func _init() -> void:
    # TODO: Validation checks to set default inventory data
    
    if backpack.size() < max_backpack_slots:
        backpack.resize(max_backpack_slots)


#region Equipped Mask
func get_equipped_mask() -> Variant: # TODO: Return mask object type
    return equipped.mask


func set_equipped_mask(new_equipped_mask: Variant) -> void: # TODO: Update param to be mask-item type
    Globals.logger.debug("Setting new equipped mask: New Mask: %s | Prev Mask: %s" % [new_equipped_mask, equipped.mask])
    equipped.mask = new_equipped_mask
#endregion


#region Equipped Echoes
func get_equipped_echoes() -> Array[Variant]: # TODO: Return Array of echo object type
    return equipped.echoes


func set_equipped_echo_slot(slot_index: int, new_echo: Variant) -> void: # TODO: Update param to echo-item type
    if equipped.echoes.get(slot_index) == null:
        Globals.logger.error("Can not set equipped echo for invalid index! Index: %s | Echos Size: %s" % [slot_index, equipped.echoes.size()])
        return
    
    # TODO: Update typing to accomodate Array of echo-item objects
    var prev_echo: Variant = equipped.echoes.get(slot_index)
    Globals.logger.debug("Setting equipped echo slot. Index: %s | New Echo: %s | Prev Echo: %s", [slot_index, new_echo, prev_echo])
    equipped.echoes.set(slot_index, new_echo)
#endregion


#region Backpack
func get_backpack_item(slot_index: int) -> Variant: # TODO: Return item object type
    if !backpack_slot_valid(slot_index):
        Globals.logger.error("Can not retrieve invalid slot index in backpack! Index: %s | Backpack Size: %s" % [slot_index, backpack.size()])
        return
        
    return backpack.get(slot_index)


func set_backpack_slot(slot_index: int, item: Variant) -> void: # TODO: Set param to item object type
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
