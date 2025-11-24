class_name MenuLayer
extends CanvasLayer

@onready var inventory_ui: InventoryUI = %InventoryUI
@onready var player: Player = %Player


func open_inventory() -> void:
    print("Opening player inventory!")
    # Remove player control
    Globals.signal_bus.allow_character_control.emit(false)
    # Show inventory panel
    inventory_ui.show()
    show()


func close_inventory() -> void:
    print("Closing player inventory!")
    # Hide inventory panel
    hide()
    inventory_ui.hide()
    # Return player control
    Globals.signal_bus.allow_character_control.emit(true)


func _on_inventory_menu_input() -> void:
    if _inventory_is_open():
        close_inventory()
    else:
        open_inventory()


func _inventory_is_open() -> bool:
    return inventory_ui.visible


func _ready() -> void:
    Globals.signal_bus.open_inventory.connect(_on_inventory_menu_input)
    
    inventory_ui.hide()
    
