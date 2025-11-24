class_name InventoryUI extends PanelContainer

const ITEM_SLOT: PackedScene = preload("uid://nbaglwtf3v0k")

@onready var mask_slot: ItemSlot = %MaskSlot
@onready var weapon_left_slot: ItemSlot = %WeaponLeftSlot
@onready var weapon_right_slot: ItemSlot = %WeaponRightSlot
@onready var shoulders_slot: ItemSlot = %ShouldersSlot
@onready var torso_slot: ItemSlot = %TorsoSlot
@onready var legs_slot: ItemSlot = %LegsSlot

@onready var echoes_container: HBoxContainer = %EchoesContainer

@onready var backpack_grid: GridContainer = %BackpackGrid

var inventory: Inventory:
    set = set_inventory

# Used when tracking what slots the player might want to swap between
var initial_item_slot: ItemSlot
var target_item_slot: ItemSlot

var backpack_slots :=  8 * 2 # Items per row x Num rows


func put_item_in_slot(item: Item, item_slot: ItemSlot) -> void:
    item_slot.item = item
    # TODO: Update inventory item


func swap_slot_items(initial_slot: ItemSlot, target_slot: ItemSlot) -> void:
    var initial_item := initial_item_slot.item
    put_item_in_slot(target_slot.item, initial_item_slot)
    put_item_in_slot(initial_item, target_slot)


func set_inventory(new_inventory) -> void:
    inventory = new_inventory
        
    if inventory != null:
        # Set primary equipment
        mask_slot.set_item(inventory.equipment.mask)
        weapon_left_slot.set_item(inventory.equipment.weapon_left)
        weapon_right_slot.set_item(inventory.equipment.weapon_right)
        shoulders_slot.set_item(inventory.equipment.shoulders)
        torso_slot.set_item(inventory.equipment.torso)
        legs_slot.set_item(inventory.equipment.legs)
        
        # Set equipped Echoes
        var echo_slots := echoes_container.get_children()
        for i in range(0, echo_slots.size()):
            var echo_slot: ItemSlot = echo_slots.get(i)
            wire_slot_signals(echo_slot)
            echo_slot.set_acceptable_item_callback(
                slot_can_accept_item.bind(EchoItem)
            )
            # This may throw an error, but we are checking for this state here explicitly. Currently choosing to ignore the error, but later the inventory logic should be more solidified and we can build more robust code.
            if inventory.equipment.echoes.get(i) != null:
                echo_slot.set_item(inventory.equipment.echoes.get(i))
        
        # Set backpack slots
        for i in range(0, inventory.backpack.size()):
            if inventory.backpack[i] != null:
                var backpack_item_slot: ItemSlot = backpack_grid.get_child(i)
                backpack_item_slot.set_item(inventory.backpack[i])


func slot_can_accept_item(item: Item, item_type: Variant) -> bool:
    # TODO: Create logic to handle when potentially swapping items
    #       - If the 'initial_item_slot' is valid then we need to check if the item in the target slot can fit in the 'initial_item_slot AND that the item in the 'initial_item_slot' can fit in the target slot.
    #       - May need to assign the item type to the ItemSlot itself...
    return is_instance_of(item, item_type)


func handle_received_item_in_slot(item: Item, item_slot: ItemSlot) -> void:
    #print("UI noted that slot received item")
    if initial_item_slot != null:
        # Ensure that we don't just put an item back in its original slot
        if initial_item_slot != item_slot:
            # Trigger a swap
            swap_slot_items(initial_item_slot, item_slot)
            initial_item_slot = null
    else:
        put_item_in_slot(item, item_slot)


func handle_item_slot_selected(item_slot: ItemSlot) -> void:
    #print("UI noting that slot was selected")
    pass


func handle_item_slot_interacted(item_slot: ItemSlot) -> void:
    #print("UI noting that slot was interacted with")
    initial_item_slot = item_slot


func wire_slot_signals(item_slot: ItemSlot) -> void:
    item_slot.selected.connect(handle_item_slot_selected.bind(item_slot))
    item_slot.received_item.connect(handle_received_item_in_slot.bind(item_slot))
    item_slot.interacted.connect(handle_item_slot_interacted.bind(item_slot))


func _create_item_slot() -> ItemSlot:
    var new_item_slot: ItemSlot = ITEM_SLOT.instantiate()
    #new_item_slot.set_acceptable_item_callback(slot_can_accept_item)
    wire_slot_signals(new_item_slot)
    return new_item_slot


func _wire_equipment_slots() -> void:
    mask_slot.set_acceptable_item_callback(slot_can_accept_item.bind(MaskItem))
    wire_slot_signals(mask_slot)
    
    weapon_left_slot.set_acceptable_item_callback(slot_can_accept_item.bind(WeaponItem))
    wire_slot_signals(weapon_left_slot)
    
    weapon_right_slot.set_acceptable_item_callback(slot_can_accept_item.bind(WeaponItem))
    wire_slot_signals(weapon_right_slot)
    
    # TODO: Update these when new item types exist. These can effectively take anything
    shoulders_slot.set_acceptable_item_callback(slot_can_accept_item.bind(ShoulderItem))
    wire_slot_signals(shoulders_slot)
    
    torso_slot.set_acceptable_item_callback(slot_can_accept_item.bind(TorsoItem))
    wire_slot_signals(torso_slot)
    
    legs_slot.set_acceptable_item_callback(slot_can_accept_item.bind(LegsItem))
    wire_slot_signals(legs_slot)


func _ready() -> void:
    _wire_equipment_slots()
    _clear_preview_slots_on_load()
    
    for i in range(0, backpack_slots):
        var new_backpack_slot := _create_item_slot()
        backpack_grid.add_child(new_backpack_slot)


func _clear_preview_slots_on_load() -> void:
    var preview_backpack_slots := backpack_grid.get_children()
    for slot: Control in preview_backpack_slots:
        slot.queue_free()
    
