extends Node3D

#region Onready vars
@onready var game_world_ui_layer: CanvasLayer = %GameWorldUILayer
@onready var testing_ui_layer: CanvasLayer = %TestingUILayer
@onready var camera_3d: Camera3D = %Camera3D

@onready var test_ui_button: Button = %TestUIButton

@onready var inventory_component: InventoryComponent = %InventoryComponent

@onready var equipped_mask_value: LineEdit = %EquippedMaskValue
@onready var equipped_echoes_container: HBoxContainer = %EquippedEchoesContainer
@onready var backpack_items_list: FlowContainer = %BackpackItemsList
@onready var debug_text: TextEdit = %DebugText

@onready var inventory_ui: InventoryUI = %InventoryUI

@onready var update_inventory_button: Button = %UpdateInventoryButton
@onready var close_inventory_button: Button = %CloseInventoryButton
#endregion


func show_test_ui() -> void:
    game_world_ui_layer.hide()
    testing_ui_layer.show()


func show_game_ui() -> void:
    testing_ui_layer.hide()
    game_world_ui_layer.show()


func update_inventory_from_test() -> void:
    # Collect our test values
    var mask := equipped_mask_value.text
    
    var echoes: Array
    var echo_values := equipped_echoes_container.get_children()
    for echo: LineEdit in echo_values:
        echoes.push_back(echo.text)
    
    var items: Array
    var item_values := backpack_items_list.get_children()
    for item: LineEdit in item_values:
        items.push_back(item.text)
    
    # Set our new test values into the inventory
    #inventory_component.inventory.set_equipped_mask(mask)
    
    #for echo: Variant in echoes:
        #inventory_component.inventory.set_equipped_echo_slot(
            #echoes.find(echo), echo
        #)
    #
    #for item: Variant in items:
        #inventory_component.inventory.set_backpack_slot(items.find(item), item)


func set_debug_text() -> void:
    var equipped_mask: Variant = inventory_component.inventory.equipped.mask
    var equipped_echoes: Array[Variant] = inventory_component.inventory.equipped.echoes
    var backpack: Array[Variant] = inventory_component.inventory.backpack
    
    var print_object := {
        "mask": equipped_mask,
        "echoes": equipped_echoes,
        "backpack": backpack,
    }
    
    var printable_text := JSON.stringify(print_object, "    ", false)
    debug_text.text = printable_text


func update_inventory_and_debug_text() -> void:
    update_inventory_from_test()
    set_debug_text()


func _ready() -> void:
    # Hacks to disable global camera and input stuff
    camera_3d.make_current()
    Globals.camera.queue_free()
    Globals.input.queue_free()
    
    show_game_ui()
    
    inventory_ui.set_inventory(inventory_component.inventory)

    test_ui_button.pressed.connect(show_test_ui)
    close_inventory_button.pressed.connect(show_game_ui)
    update_inventory_button.pressed.connect(update_inventory_and_debug_text)
