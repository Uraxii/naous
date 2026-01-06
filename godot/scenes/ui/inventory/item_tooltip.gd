class_name ItemTooltip
extends PanelContainer

@onready var item_title: Label = %ItemTitle
@onready var item_type: Label = %ItemType
@onready var item_data: VBoxContainer = %ItemData
@onready var item_description: RichTextLabel = %ItemDescription

var current_item: Item


func show_with_item(item: Item) -> void:
    current_item = item
    set_item_content(current_item)


func set_item_content(item: Item) -> void:
    item_title.text = item.name
    item_type.text = get_item_type_display(item)
    item_description.text = item.description


func get_item_type_display(item: Item) -> String:
    if item is EchoItem:
        return "Echo"
    elif item is MaskItem:
        return "Mask"
    elif item is WeaponItem:
        return "Weapon"
    elif item is ShoulderItem:
        return "Shoulders"
    elif item is TorsoItem:
        return "Torso"
    elif item is LegsItem:
        return "Legs"
    elif item is Item: # Check this base class last
        return "Item"
    
    return "UNKNOWN"
