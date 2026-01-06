class_name ItemTooltipPopup
extends PopupPanel

const OFFSET := Vector2(5,5)

var item:
    get = get_item,
    set = set_item

@onready var item_tooltip: ItemTooltip = $ItemTooltip


func show_at_position(screen_pos: Vector2) -> void:
    position = screen_pos + OFFSET
    reset_size()


func set_item(new_item: Item) -> void:
    item_tooltip.show_with_item(new_item)


func get_item() -> Item:
    return item_tooltip.current_item


func _ready() -> void:
    gui_disable_input = true
