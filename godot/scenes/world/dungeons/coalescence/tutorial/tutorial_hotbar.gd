class_name TutorialHotbar
extends HBoxContainer

@onready var hotbutton_one: Button = %HotbuttonOne
@onready var hotbutton_two: Button = %HotbuttonTwo
@onready var hotbutton_three: Button = %HotbuttonThree
@onready var hotbutton_four: Button = %HotbuttonFour

@onready var hotbuttons: Array[Button] = [
    hotbutton_one,
    hotbutton_two,
    hotbutton_three,
    hotbutton_four,
]

var assigned_entity: Entity


func match_echoes(echoes: Array[EchoItem]) -> void:
    for i in range(0, echoes.size()):
        var current_echo: EchoItem = echoes[i]
        var hotbutton: Button = hotbuttons[i]
        if is_instance_valid(current_echo):
            hotbutton.icon = current_echo.icon
        else:
            hotbutton.icon = null


func activate_inventory_echo(index: int) -> void:
    var assigned_spellbook: ComponentSpellbook = assigned_entity.components.find("Spellbook")
    assigned_spellbook.cast_echo_from_inventory(index)


func assign_entity(new_entity: Entity) -> void:
    assigned_entity = new_entity
    
    var assigned_inventory: InventoryComponent = assigned_entity.components.find("Inventory")
    if is_instance_valid(assigned_inventory):
        assigned_inventory.inventory.equipped_echoes_updated.connect(match_echoes)


func _ready() -> void:
    hotbutton_one.pressed.connect(activate_inventory_echo.bind(0))
    hotbutton_two.pressed.connect(activate_inventory_echo.bind(1))
    hotbutton_three.pressed.connect(activate_inventory_echo.bind(2))
    hotbutton_four.pressed.connect(activate_inventory_echo.bind(3))
