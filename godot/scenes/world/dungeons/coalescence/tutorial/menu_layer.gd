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
    inventory_ui.inventory_audio_manager.play_opened()
    inventory_opened.emit()


func close_inventory() -> void:
    print("Closing player inventory!")
    # Hide inventory panel
    inventory_ui.hide()
    inventory_ui.inventory_audio_manager.play_closed()
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
    
    _connect_inventory.call_deferred()
    inventory_ui.hide()


func _connect_inventory() -> void:
    inventory_ui.set_inventory(player.inventory.inventory)
