class_name MenuLayer
extends CanvasLayer

@onready var inventory_ui: InventoryUI = %InventoryUI
@onready var player: Player = %Player

var _original_player_velocity: float

func open_inventory() -> void:
    print("Opening player inventory!")
    # Remove player control
    var player_speed_c: StatComponent = player.components.find("Speed")
    # HACK: Hack to prevent movement
    _original_player_velocity = player_speed_c.current
    player_speed_c.current = 0
    # Show inventory panel
    inventory_ui.show()


func close_inventory() -> void:
    print("Closing player inventory!")
    # Hide inventory panel
    inventory_ui.hide()
    # Return player control
    var player_speed_c: StatComponent = player.components.find("Speed")
    player_speed_c.current = _original_player_velocity


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
