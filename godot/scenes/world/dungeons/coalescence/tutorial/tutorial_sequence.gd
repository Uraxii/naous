class_name TutorialSequence
extends Node

signal sequence_changed(sequence: SEQ)

## States of the sequence
enum SEQ {
    # Player is just spawned at the entry to the ruins
    #  GOAL: pick up starter gear set
    BEGINNING,
    # Player picked up a pack of starter gear (Echoes, Mask, etc.)
    #  GOAL: complete learning tutorial on equipment (UI-based)
    GEAR_TUTORIAL, 
    # Player now has attacks, directed to destroy the boulder
    #  GOAL: attempt to attack and destroy the boulder (reduce its health to 0)
    DESTROY_BARRICADE, 
    # Enemy (Archa) bursts through the boulder and attacks the player
    #  GOAL: Defeat the enemy (reduce its health to 0)
    FIRST_COMBAT, 
    # Defeating this first enemy drops a new Echo for healing
    #  GOAL: Equip and use the healing ability to restore health
    HEAL_TUTORIAL, 
    # Player is directed to explore the new area to defeat enemies and acquire more gear (mostly Masks)
    #  GOAL: Defeat 3 enemies and acquire 3 items (Masks)
    EXPLORE_PLAZA, 
    # Enemies have been defeated and items collected. A new enemy appears
    #  GOAL: Defeat the miniboss
    MINIBOSS_FIGHT,
    # Miniboss is defeated and drops an Echo
    #  GOAL: Learn about Draw limitations (UI tutorial), equip Echoes as desired, close equipment screen
    DRAW_TUTORIAL,
    # A horde of enemies appears, player should fight them in a designated area for a bit
    #  GOAL: Defeat X number of enemies or survive for X seconds
    HORDE_FIGHT,
    # After some fighting, allies appear (mimicking players) to support
    #  GOAL: Defeat X more enemies or survive for X more seconds
    BACKUP_ARRIVES,
    # Large boss attacks and chases player out of the area
    #  GOAL: Run back to entrance and trigger level transition
    ESCAPE
}

@onready var player: Player = %Player
@onready var hud_layer: HUDLayer = %HUDLayer
@onready var screen_overlay: ScreenOverlayLayer = %ScreenOverlayLayer
@onready var menu_layer: MenuLayer = %MenuLayer
@onready var first_enemy: BaseEnemy = %FirstEnemy

var current_sequence: SEQ:
    set = set_current_sequence


func start() -> void:
    trigger_sequence(SEQ.BEGINNING)


#region Sequence Functions
#region BEGINNING
@onready var player_spawn_position: Marker3D = %PlayerSpawnPosition
@onready var starter_gear_pickup: LootPickup = %StarterGearPickup
func beginning() -> void:
    print("STARTING BEGINNING SEQUENCE")
    current_sequence = SEQ.BEGINNING
    # 1. Set camera to black, prevent player control
    screen_overlay.hide_screen()
    # TODO: Disable ability for player top open inventory until next sequence
    Globals.signal_bus.allow_character_control.emit(false)
    
    # 2. Spawn player in starting position
    var player_body_c: Node3D = player.components.find("Body")
    player_body_c.global_position = player_spawn_position.global_position
    # 3. Fade in screen to show character (with letterbox?)
    screen_overlay.fade_in_complete.connect(_on_beginning_hud_fade_in)
    screen_overlay.fade_in()


func _on_beginning_hud_fade_in() -> void:
    print("BEGINNING: Hud faded in, re-enabling character control")
    screen_overlay.fade_in_complete.disconnect(_on_beginning_hud_fade_in)
    # 4. Give player control (remove letterbox?)
    Globals.signal_bus.allow_character_control.emit(true)
    hud_layer.display_objective_hud("Explore the ruins")
    
    starter_gear_pickup.collected.connect(_on_beginning_gear_pickup)


func _on_beginning_gear_pickup() -> void:
    print("BEGINNING: Player picked up starter gear")
    # 5. When player picks up starter gear, trigger next sequence
    starter_gear_pickup.collected.disconnect(_on_beginning_gear_pickup)
    starter_gear_pickup.queue_free()
    trigger_sequence(SEQ.GEAR_TUTORIAL)
#endregion BEGINNING


#region GEAR TUTORIAL
const STARTER_MASK: MaskItem = preload("uid://dk0erx4ii1d1l")
const STARTER_ECHOES: Array[EchoItem] = [
    preload("uid://iyvy1qavlxb7"),
    preload("uid://c1nk8bluat4xw"),
]
const STARTER_WEAPON: WeaponItem = preload("uid://b7eyqhnr5cqgo")
func gear_tutorial() -> void:
    print("STARTING GEAR TUTORIAL SEQUENCE")
    current_sequence = SEQ.GEAR_TUTORIAL
    # 1. Open inventory/equipment view
    hud_layer.display_objective_hud("Open Inventory")
    menu_layer.inventory_opened.connect(_on_inventory_opened_with_starter_gear)
    # 1a. Put the items in the player's inventory
    player.inventory.inventory.add_to_backpack(STARTER_MASK)
    player.inventory.inventory.add_to_backpack(STARTER_WEAPON)
    player.inventory.inventory.add_to_backpack(STARTER_ECHOES[0])
    player.inventory.inventory.add_to_backpack(STARTER_ECHOES[1])


func _on_inventory_opened_with_starter_gear() -> void:
    # 2. Display items that have been "picked up" (Echoes)
    # TODO: Add some tutorial overlays or toast messages or something
    # 3. Display tutorial UI teaching how to equip the Echoes
    # TODO: Show how to equip the items
    player.inventory.inventory.equipment_updated.connect(
        _on_inventory_updated_with_starter_gear)
    player.inventory.inventory.equipped_echoes_updated.connect(
        _on_equipped_echoes_updated_with_starter_gear)


func _on_inventory_updated_with_starter_gear(_equipment: Equipment) -> void:
    _validate_starter_gear_equipped()

func _on_equipped_echoes_updated_with_starter_gear(_echoes: Array[EchoItem]) -> void:
    _validate_starter_gear_equipped()


func _validate_starter_gear_equipped() -> void:
    # Confirm the gear is equipped
    var player_equipment: Equipment = player.inventory.inventory.equipment
    if player_equipment.mask == STARTER_MASK and\
    (
        player_equipment.weapon_left == STARTER_WEAPON or player_equipment.weapon_right == STARTER_WEAPON
    ) and\
    player_equipment.echoes[0] in STARTER_ECHOES and\
    player_equipment.echoes[1] in STARTER_ECHOES:
        # 4. Prompt to close inventory
        Globals.logger.debug("Player equipped all the gear")
        # TODO: Use the overlay and such mentioned above
        menu_layer.inventory_closed.connect(_on_inventory_closed_with_starter_gear)


func _on_inventory_closed_with_starter_gear() -> void:
    Globals.logger.debug("Player closed inventory after equipping starter gear")
    # 4a. (optional) Show newly equipped abilities in HUD (Hotbar)
    # TODO: Use some overlay/highlight UI to show the abilities in the hotbar
    # 5. When inventory/UI is resolved, trigger next sequence
    player.inventory.inventory.equipment_updated.disconnect(
        _on_inventory_updated_with_starter_gear)
    player.inventory.inventory.equipped_echoes_updated.disconnect(
        _on_equipped_echoes_updated_with_starter_gear)
    menu_layer.inventory_closed.disconnect(_on_inventory_closed_with_starter_gear)
    menu_layer.inventory_opened.disconnect(_on_inventory_opened_with_starter_gear)
    trigger_sequence(SEQ.DESTROY_BARRICADE)
#endregion GEAR TUTORIAL


#region DESTROY BARRICADE
@onready var entry_path: EntryPath = %EntryPath
func destroy_barricade() -> void:
    Globals.logger.debug("STARTING DESTROY BARRICADE SEQUENCE")
    current_sequence = SEQ.DESTROY_BARRICADE
    # 1. Show/Highlight the boulder blocking the path forward
    # TODO: Camera cutscene? Remove player control briefly and point towards the boulder (or pan entirely over to show it)
    # 2. Prompt player to destroy the boulder using their new attack ability
    hud_layer.display_objective_hud("Destroy the boulder")
    # 3. When the boulder reaches low health, trigger next sequence
    entry_path.arched_gateway.rubble_entity.health.change.connect(
        _on_barricade_health_changed)


func _on_barricade_health_changed(new: float, _old: float) -> void:
    var percentage_health := new / entry_path.arched_gateway.rubble_entity.health.max_value
    if percentage_health <= 0.2: # Less than 20% health
        entry_path.arched_gateway.rubble_entity.health.change.disconnect(
        _on_barricade_health_changed)
        trigger_sequence(SEQ.FIRST_COMBAT)
#endregion DESTROY BARRICADE


#region FIRST COMBAT
@onready var first_enemy_initial: Marker3D = %FirstEnemyInitial
func first_combat() -> void:
    Globals.logger.debug("STARTING FIRST COMBAT SEQUENCE")
    current_sequence = SEQ.FIRST_COMBAT
    # 1. Start "cutscene" where enemy bursts through boulder (potentially damaging the player slightly - this ensures they have health to recover with the upcoming heal ability)
    _play_first_combat_enemy_reveal()


const FIRST_ENEMY_REVEAL_TIME: float = 2.0
@onready var first_enemy_reveal_position: Marker3D = %FirstEnemyRevealPosition
func _play_first_combat_enemy_reveal() -> void:
    # Warp the enemy to the start and then tween it towards the target position
    # - It's breaking through the boulder
    first_enemy.body.global_position = first_enemy_initial.global_position
    var tween := get_tree().create_tween()
    tween.tween_property(first_enemy.body, "global_position", first_enemy_reveal_position.global_position, FIRST_ENEMY_REVEAL_TIME)
    tween.tween_callback(_first_enemy_reached_target_position)


const FIRST_ENEMY_HOLD_TIME: float = 3.0
func _first_enemy_reached_target_position() -> void:
    # Let the enemy hold in position for a moment for DRAMATIC EFFECT
    player.health.current = player.health.current * 0.8
    get_tree().create_timer(FIRST_ENEMY_HOLD_TIME).timeout.connect(
        _after_first_enemy_hold)


func _after_first_enemy_hold() -> void:
    # 2. Prompt player to target and attack the enemy (just like they did with the boulder)
    print("RAWR")
    hud_layer.display_objective_hud("Return the enemy to Naous")
    first_enemy.process_mode = Node.PROCESS_MODE_INHERIT
    first_enemy.defeated.connect(_on_first_enemy_defeated)


@onready var heal_echo_pickup: LootPickup = %HealEchoPickup
func _on_first_enemy_defeated() -> void:
    first_enemy.defeated.disconnect(_on_first_enemy_defeated)
    # Move the heal pickup to where the enemy was (ie. it "dropped" on defeat)
    heal_echo_pickup.global_position = first_enemy.body.global_position
    first_enemy.queue_free()
    # 3. When the enemy is defeated, trigger next sequence
    trigger_sequence(SEQ.HEAL_TUTORIAL)
#endregion FIRST COMBAT


#region HEAL TUTORIAL
const HEAL_ECHO = preload("uid://dqwvsj4f1p0hd")
func heal_tutorial() -> void:
    Globals.logger.debug("STARTING HEAL SEQUENCE")
    current_sequence = SEQ.HEAL_TUTORIAL
    # 1. Enemy dropped a new Echo for self-healing
    # 2. Prompt player to pick up Echo
    hud_layer.display_objective_hud("Pickup Item")
    heal_echo_pickup.collected.connect(_on_heal_pickup)


func _on_heal_pickup() -> void:
    heal_echo_pickup.collected.disconnect(_on_heal_pickup)
    heal_echo_pickup.queue_free()
    # 3. Prompt player to open inventory to equip it (or maybe we auto-equip it?)
    # 4. Once equipped, prompt player to use self-heal to recover health
    hud_layer.display_objective_hud("Equip Echo and Heal")
    player.health.change.connect(_on_player_healed)
    player.inventory.inventory.add_to_backpack(HEAL_ECHO)


func _on_player_healed(_new: float, _old: float) -> void:
    # 5. Once health is restored, trigger next sequence
    trigger_sequence(SEQ.EXPLORE_PLAZA)
#endregion HEAL TUTORIAL


#region EXPLORE PLAZA
func explore_plaza() -> void:
    Globals.logger.debug("STARTING EXPLORE PLAZA SEQUENCE")
    current_sequence = SEQ.EXPLORE_PLAZA
    # 1. Remove collision preventing player from progressing as necessary (maybe it looks like the healing burst applies an impulse to the boulder rubble that finishes moving it out of the way)
    entry_path.arched_gateway.delete_rubble()
    # 2. Show the open plaza with roaming enemies and shiny pick-up items
    # 3. Prompt the user to explore the area
    # 3a. Sub-objectives: Defeat 3 enemies, Collect 3 Masks
    # 4. When a mask is picked up, prompt to open inventory
    # 5. Once inventory is open, show Mask equip tutorial explaining what they do
    # 6. When all enemies are defeated and Masks are collected, trigger next sequence
    pass
#endregion EXPLORE PLAZA


#region MINIBOSS FIGHT
func miniboss_fight() -> void:
    Globals.logger.debug("STARTING MINIBOSS SEQUENCE")
    current_sequence = SEQ.MINIBOSS_FIGHT
    # 1. Show "cutscene" of miniboss entering the area
    # 2. Prompt player to defeat the miniboss
    # 3. When the enemy is defeated, trigger next sequence
    pass
#endregion MINIBOSS FIGHT


#region DRAW TUTORIAL
func draw_tutorial() -> void:
    Globals.logger.debug("STARTING DRAW SEQUENCE")
    current_sequence = SEQ.DRAW_TUTORIAL
    # 1. The defeated miniboss drops a new Echo (with a higher Draw cost)
    # 2. Prompt player to open the inventory
    # 3. Once inventory is open, show tutorial explaining Draw cost and how it limits how many/what Echoes you can have equipped.
    # 4. Prompt user to adjust Echoes as desired and then close inventory
    # 5. When inventory is closed, trigger next sequence
    pass
#endregion DRAW TUTORIAL


#region HORDE FIGHT
func horde_fight() -> void:
    Globals.logger.debug("STARTING HORDE SEQUENCE")
    current_sequence = SEQ.HORDE_FIGHT
    # 1. Show "cutscene" of roars and rumbles
    # 2. Spawn some enemies and have them jump into the scene
    # 3. Highlight a designated area for the player to move to (should mostly be where they were)
    # 4. Prompt player to fend off the horde
    # 5. After 3 enemies are defeated, trigger next sequence
    pass
#endregion HORDE FIGHT


#region BACKUP ARRIVES
func backup_arrives() -> void:
    Globals.logger.debug("STARTING BACKUP SEQUENCE")
    current_sequence = SEQ.BACKUP_ARRIVES
    # 1. Show "cutscene" of allies jumping in to help
    # 2. Startup "allies" as static characters that attack enemies and support the player
    # 3. Prompt player to continue fending off the horde
    # When several more enemies are defeated or after X time has passed, trigger next sequence
    pass
#endregion BACKUP ARRIVES


#region ESCAPE
func escape() -> void:
    Globals.logger.debug("STARTING ESCAPE SEQUENCE")
    current_sequence = SEQ.ESCAPE
    # 1. Show "cutscene" of large boss enemy smashing into the scene and defeating some allies
    # 2. Prompt player to retreat and find help
    # 3. Highlight the entrance/exit for the player to move towards, point player camera in that direction
    # 4. Activate level transition collision at the exit of the area
    # 5. When player reaches level transition, let level transition occur and resolve sequence
    pass
#endregion ESCAPE
#endregion Sequence Functions


func trigger_sequence(sequence: SEQ) -> void:
    match sequence:
        SEQ.BEGINNING:
            beginning()
        SEQ.GEAR_TUTORIAL:
            gear_tutorial()
        SEQ.DESTROY_BARRICADE:
            destroy_barricade()
        SEQ.FIRST_COMBAT:
            first_combat()
        SEQ.HEAL_TUTORIAL:
            heal_tutorial()
        SEQ.EXPLORE_PLAZA:
            explore_plaza()
        SEQ.MINIBOSS_FIGHT:
            miniboss_fight()
        SEQ.DRAW_TUTORIAL:
            draw_tutorial()
        SEQ.HORDE_FIGHT:
            horde_fight()
        SEQ.BACKUP_ARRIVES:
            backup_arrives()
        SEQ.ESCAPE:
            escape()


func set_current_sequence(new_sequence: SEQ) -> void:
    if current_sequence != new_sequence:
        current_sequence = new_sequence
        sequence_changed.emit(current_sequence)


func _ready() -> void:
    pass
