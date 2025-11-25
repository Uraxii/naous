class_name MenuLayer
extends CanvasLayer

signal inventory_opened
signal inventory_closed

@onready var inventory_ui: InventoryUI = %InventoryUI
@onready var player: Player = %Player


func open_inventory() -> void:
    print("Opening player inventory!")
    # Remove player control
    Globals.signal_bus.allow_character_control.emit(false)
    # Show inventory panel
    inventory_ui.show()
    show()
    inventory_opened.emit()


func close_inventory() -> void:
    print("Closing player inventory!")
    # Hide inventory panel
    hide()
    inventory_ui.hide()
    # Return player control
    Globals.signal_bus.allow_character_control.emit(true)
    inventory_closed.emit()


func _on_inventory_menu_input() -> void:
    if _inventory_is_open():
        close_inventory()
    else:
        open_inventory()


func _inventory_is_open() -> bool:
    return inventory_ui.visible


func _ready() -> void:
    Globals.signal_bus.open_inventory.connect(_on_inventory_menu_input)
    
    inventory_ui.set_inventory.call_deferred(player.inventory.inventory)
    inventory_ui.hide()
    
