class_name InventoryUI extends PanelContainer

const ITEM_SLOT: PackedScene = preload("uid://nbaglwtf3v0k")
@onready var backpack_grid: GridContainer = %BackpackGrid

var inventory: Inventory:
    set = set_inventory

# Used when tracking what slots the player might want to swap between
var initial_item_slot: ItemSlot
var target_item_slot: ItemSlot

var backpack_slots :=  8 * 4 # 8 items per row, 4 rows


func put_item_in_slot(item: Item, item_slot: ItemSlot) -> void:
    item_slot.item = item


func swap_slot_items(initial_slot: ItemSlot, target_slot: ItemSlot) -> void:
    var initial_item := initial_item_slot.item
    initial_item_slot.item = target_slot.item
    target_slot.item = initial_item


func remove_item_from_slot(item_slot: ItemSlot) -> void:
    pass


func set_inventory(new_inventory) -> void:
    inventory = new_inventory
        
    if inventory != null:
        for i in range(0, inventory.backpack.size()):
            if inventory.backpack[i] != null:
                var backpack_item_slot: ItemSlot = backpack_grid.get_child(i)
                backpack_item_slot.set_item(inventory.backpack[i])


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


func _ready() -> void:
    for i in range(0, backpack_slots):
        var new_backpack_slot: ItemSlot = ITEM_SLOT.instantiate()
        backpack_grid.add_child(new_backpack_slot)
        wire_slot_signals(new_backpack_slot)
