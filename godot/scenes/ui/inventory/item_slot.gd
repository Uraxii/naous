class_name ItemSlot extends PanelContainer

signal selected
signal interacted
signal received_item(item: Item)
signal removed_item(item: Item)

const ITEM_SLOT_ICON: PackedScene = preload("uid://cf10alpcpeo8n")

@onready var item_icon: TextureRect = %ItemSlotIcon
var set_inventory_item_callback: Callable = Callable()

var item: Item:
    set = set_item

var _acceptable_item_callback: Callable:
    set = set_acceptable_item_callback


func set_acceptable_item_callback(new_callback: Callable) -> void:
    _acceptable_item_callback = new_callback


func has_item() -> bool:
    return item != null


func set_item(new_item: Item) -> void:
    if new_item == null:
        item = null
        item_icon.texture = null
        if set_inventory_item_callback.is_valid():
            set_inventory_item_callback.call(null)
    else:
        item = new_item
        item_icon.texture = item.icon
        if set_inventory_item_callback.is_valid():
            set_inventory_item_callback.call(item)


func remove_item() -> Item:
    var old_item := item
    set_item(null)
    removed_item.emit(old_item)
    return old_item


func emit_selected() -> void:
    selected.emit()


func gained_focus() -> void:
    # TODO: Change panel to the default panel (theme variation maybe)
    grab_focus()
    emit_selected()


func lost_focus() -> void:
    # TODO: Change panel to a "on-hover" panel (theme variation maybe)
    pass


func received_interaction() -> void:
    if item != null:
        interacted.emit()


#region Draggable
# Called when the drag operation initially starts
func _get_drag_data(at_position: Vector2) -> Item:
    #print("Getting draggable data from item slot")
    var item_data: Item
    if item != null:
        item_data = item # The data we'll return help preview the drag
        
        # Set a draggable preview to the cursor
        var icon_preview := item_icon.duplicate()
        icon_preview.self_modulate.a = 0.85 # Make it slightly transparent for visual clarity
        set_drag_preview(icon_preview)
    return item_data


# Called for every frame the mouse is moving while over this Control and dragging is in effect
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
    #print("Item slot is being dragged -> " + name)
    if not data is Item:
        return false
    
    if _acceptable_item_callback.is_valid():
        return _acceptable_item_callback.call(data)
    
    return true


# Called when a drop is triggered after a drag
func _drop_data(at_position: Vector2, data: Variant) -> void:
    if data != null and data != item:
        #print("Item slot dropping data")
        received_item.emit(data)
#endregion


func _ready() -> void:
    if not is_instance_valid(item_icon):
        var new_texture_rect := ITEM_SLOT_ICON.instantiate()
        add_child(new_texture_rect)
        item_icon = new_texture_rect
    
    focus_entered.connect(gained_focus)
    mouse_entered.connect(grab_focus)
    mouse_exited.connect(lost_focus)


func _gui_input(event: InputEvent) -> void:
    if event.is_pressed() and (event.is_action("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
        received_interaction()
