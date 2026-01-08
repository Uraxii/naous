class_name TutorialSequence
extends Node

signal sequence_changed(sequence: SEQ)
signal spawn_entity_at(entity: Entity, location: Vector3)
signal despawn_entity(entity: Entity)

const CREDITS_SCENE: PackedScene = preload("uid://bovh2hjexu5yl")
const TEST_SKIP_TO_CREDITS: bool = false

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
    # Player is directed to equip a new mask?
    #  GOAL: Equip the new mask?
    MASK_TUTORIAL,
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

@onready var tutorial_music: TutorialMusic = %TutorialMusic
@onready var player: Player = %Player
@onready var hud_layer: HUDLayer = %HUDLayer
@onready var screen_overlay: ScreenOverlayLayer = %ScreenOverlayLayer
@onready var menu_layer: MenuLayer = %MenuLayer

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
    tutorial_music.play_background()
    current_sequence = SEQ.BEGINNING
    # 1. Set camera to black, prevent player control
    screen_overlay.hide_screen()
    # TODO: Disable ability for player to open inventory until next sequence
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
    
    if TEST_SKIP_TO_CREDITS: ## TESTING
        _on_tutorial_fade_out()


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
    hud_layer.display_objective_hud("Open Inventory (I)")
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
    hud_layer.display_objective_hud("Equip Mask, Weapon, and Echoes")
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
    var player_equipped_mask := player_equipment.mask == STARTER_MASK
    var player_equipped_weapon := player_equipment.weapon_left == STARTER_WEAPON or player_equipment.weapon_right == STARTER_WEAPON
    var player_equipped_echoes := STARTER_ECHOES.all(func (echo):
        return player_equipment.echoes.has(echo)
    )
    if player_equipped_mask and player_equipped_weapon and player_equipped_echoes:
        # 4. Prompt to close inventory
        Globals.logger.debug("Player equipped all the gear")
        hud_layer.display_objective_hud("Close Inventory (I)")
        # TODO: Use the overlay and such mentioned above
        menu_layer.inventory_opened.disconnect(
            _on_inventory_opened_with_starter_gear)
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
    hud_layer.display_objective_hud("Destroy the boulder - target and attack with Fireball")
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
@onready var first_enemy: BaseEnemy = %FirstEnemy
@onready var first_enemy_initial: Marker3D = %FirstEnemyInitial
func first_combat() -> void:
    Globals.logger.debug("STARTING FIRST COMBAT SEQUENCE")
    tutorial_music.play_combat()
    current_sequence = SEQ.FIRST_COMBAT
    # 1. Start "cutscene" where enemy bursts through boulder (potentially damaging the player slightly - this ensures they have health to recover with the upcoming heal ability)
    _play_first_combat_enemy_reveal()


const FIRST_ENEMY_REVEAL_TIME: float = 2.0
@onready var first_enemy_reveal_position: Marker3D = %FirstEnemyRevealPosition
func _play_first_combat_enemy_reveal() -> void:
    # Warp the enemy to the start and then tween it towards the target position
    # - It's breaking through the boulder
    hud_layer.display_objective_hud("What's that sound?")
    spawn_entity_at.emit(first_enemy, first_enemy_initial.global_position)
    first_enemy.process_mode = Node.PROCESS_MODE_DISABLED
    
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
    print("RAWR") # TODO: Trigger enemy vocalization
    hud_layer.display_objective_hud("Return the enemy to Naous! Target and attack with Fireball.")
    first_enemy.process_mode = Node.PROCESS_MODE_INHERIT
    first_enemy.defeated.connect(_on_first_enemy_defeated)


@onready var heal_echo_pickup: LootPickup = %HealEchoPickup
func _on_first_enemy_defeated() -> void:
    first_enemy.defeated.disconnect(_on_first_enemy_defeated)
    # Move the heal pickup to where the enemy was (ie. it "dropped" on defeat)
    spawn_entity_at.emit(heal_echo_pickup.loot_entity, first_enemy.body.global_position)
    despawn_entity.emit(first_enemy)
    # 3. When the enemy is defeated, trigger next sequence
    trigger_sequence(SEQ.HEAL_TUTORIAL)
#endregion FIRST COMBAT


#region HEAL TUTORIAL
const HEAL_ECHO = preload("uid://dqwvsj4f1p0hd")
func heal_tutorial() -> void:
    Globals.logger.debug("STARTING HEAL SEQUENCE")
    tutorial_music.play_explore()
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
    hud_layer.display_objective_hud("Equip Healing Echo and use to recover health")
    player.health.change.connect(_on_player_healed)
    player.inventory.inventory.add_to_backpack(HEAL_ECHO)


func _on_player_healed(_new: float, _old: float) -> void:
    # 5. Once health is restored, trigger next sequence
    trigger_sequence(SEQ.EXPLORE_PLAZA)
    ## Disconnect the signal to prevent this from being triggered again.
    if player.health.change.is_connected(_on_player_healed):
        player.health.change.disconnect(_on_player_healed)
#endregion HEAL TUTORIAL


#region EXPLORE PLAZA
@onready var pyramid_archa: Archa = %PyramidArcha
@onready var pyramid_archa_spawn: Marker3D = %PyramidArchaSpawn
@onready var crystal_corner_archa: Archa = %CrystalCornerArcha
@onready var crystal_corner_spawn: Marker3D = %CrystalCornerSpawn
@onready var fountain_archa: Archa = %FountainArcha
@onready var fountain_archa_spawn: Marker3D = %FountainArchaSpawn
@onready var spawn_map := {
    pyramid_archa: pyramid_archa_spawn,
    crystal_corner_archa: crystal_corner_spawn,
    fountain_archa: fountain_archa_spawn,
}
var enemies_to_defeat: Array
var enemies_defeated: Array

const TORSO_ARMOR := preload("uid://cma2nvc1vdj5o")
const SHOULDER_ARMOR := preload("uid://bwnrnbwg67vmy")
const MAGIC_MASK := preload("uid://bw6vcgtg5adyi")
const LEG_ARMOR := preload("uid://xg4koadm3yy3")
const PHYSICAL_MASK := preload("uid://cdk7rbobh16a1")
@onready var pyramid_loot_pickup: LootPickup = %PyramidLootPickup
@onready var crystal_corner_pickup: LootPickup = %CrystalCornerPickup
@onready var fountain_loot_pickup: LootPickup = %FountainLootPickup
@onready var loot_map := {
    pyramid_loot_pickup: [PHYSICAL_MASK],
    crystal_corner_pickup: [MAGIC_MASK],
    fountain_loot_pickup: [SHOULDER_ARMOR, LEG_ARMOR, TORSO_ARMOR],
}
var loot_to_collect: Array
var loot_collected: Array

func explore_plaza() -> void:
    Globals.logger.debug("STARTING EXPLORE PLAZA SEQUENCE")
    current_sequence = SEQ.EXPLORE_PLAZA
    # 1. Remove collision preventing player from progressing as necessary (maybe it looks like the healing burst applies an impulse to the boulder rubble that finishes moving it out of the way)
    entry_path.arched_gateway.delete_rubble()
    
    # 1.1 Setup spawns and signals
    for enemy: BaseEnemy in spawn_map:
        var spawn_marker: Marker3D = spawn_map.get(enemy)
        spawn_entity_at.emit(enemy, spawn_marker.global_position)
        enemy.defeated.connect(_plaza_enemy_defeated.bind(enemy))
        enemies_to_defeat.push_back(enemy.get_instance_id())
    
    for loot_mapping: LootPickup in loot_map:
        loot_mapping.collected.connect(_plaza_item_pickup.bind(loot_mapping))
        loot_to_collect.push_back(loot_mapping.get_instance_id())
    
    # 2. Show the open plaza with roaming enemies and shiny pick-up items
    
    # 3. Prompt the user to explore the area
    _update_plaza_objective_text()


func _update_plaza_objective_text() -> void:
    var base_text := "Explore the plaza"
    # 3a. Sub-objectives: Defeat 3 enemies, Collect 3 Items
    var enemies_text := "> Enemies: [%s/%s]" % [enemies_defeated.size(), enemies_to_defeat.size()]
    var loot_text := "> Loot: [%s/%s]" % [loot_collected.size(), loot_to_collect.size()]
    
    var final_text := ""
    final_text += base_text
    final_text += "\n" + enemies_text
    final_text += "\n" + loot_text
    
    hud_layer.display_objective_hud(final_text)


func _plaza_enemy_defeated(enemy: BaseEnemy) -> void:
    enemy.defeated.disconnect(_plaza_enemy_defeated)
    tutorial_music.play_explore()
    if enemies_to_defeat.has(enemy.get_instance_id()):
        enemies_defeated.push_back(enemy.get_instance_id())
        _update_plaza_objective_text()
        despawn_entity.emit(enemy)
    
    _resolve_plaza_sequence()


func _plaza_item_pickup(loot_pickup: LootPickup) -> void:
    if loot_to_collect.has(loot_pickup.get_instance_id()):
        var loot_items: Array[Item]
        loot_items.assign(loot_map.get(loot_pickup))
        put_items_in_player_backpack(loot_items)
        loot_collected.push_back(loot_pickup.get_instance_id())
        _update_plaza_objective_text()
        loot_pickup.queue_free()
        
    _resolve_plaza_sequence()


func _resolve_plaza_sequence() -> void:
    # 6. When all enemies are defeated and Masks are collected, trigger next sequence
    if loot_collected.size() >= loot_to_collect.size() and enemies_defeated.size() >= enemies_to_defeat.size():
        # 7. Prompt to open inventory
        trigger_sequence(SEQ.MASK_TUTORIAL)
        
#endregion EXPLORE PLAZA

#region EQUIP PLAZA GEAR
func plaza_mask_tutorial() -> void:
    print("PLAZA MASK TUTORIAL SEQUENCE")
    current_sequence = SEQ.MASK_TUTORIAL
    # 1. Open inventory/equipment view
    hud_layer.display_objective_hud("Open Inventory (I)")
    menu_layer.inventory_opened.connect(_on_inventory_opened_with_plaza_gear)


func _on_inventory_opened_with_plaza_gear() -> void:
    menu_layer.inventory_opened.disconnect(_on_inventory_opened_with_plaza_gear)
    hud_layer.display_objective_hud("Take note of new equipment. Continue when ready.") ## FIXME
    ## TODO # 8. Once inventory is open, show Mask equip tutorial explaining what they do
    menu_layer.inventory_closed.connect(_on_inventory_closed_with_plaza_gear)
        
func _on_inventory_closed_with_plaza_gear() -> void:
    menu_layer.inventory_closed.disconnect(_on_inventory_closed_with_plaza_gear)
    # 5. Trigger the next sequence
    trigger_sequence(SEQ.MINIBOSS_FIGHT)
#endregion


#region MINIBOSS FIGHT
@onready var miniboss_enemy: Archa = %MinibossEnemy
@onready var miniboss_spawn: Marker3D = %MinibossSpawn
func miniboss_fight() -> void:
    Globals.logger.debug("STARTING MINIBOSS SEQUENCE")
    current_sequence = SEQ.MINIBOSS_FIGHT
    # 1. Show "cutscene" of miniboss entering the area
    spawn_entity_at.emit(miniboss_enemy, miniboss_spawn.global_position)
    miniboss_enemy.defeated.connect(_miniboss_defeated)
    # 2. Prompt player to defeat the miniboss
    hud_layer.display_objective_hud("Quell the new threat")


@onready var miniboss_loot_pickup: LootPickup = %MinibossLootPickup
func _miniboss_defeated() -> void:
    # 3. When the enemy is defeated, drop new echo
    spawn_entity_at.emit(miniboss_loot_pickup.loot_entity, miniboss_enemy.body.global_position + Vector3(0, 0.6, 0))
    miniboss_loot_pickup.collected.connect(_miniboss_gear_collected)
    despawn_entity.emit(miniboss_enemy)
    hud_layer.display_objective_hud("Pickup Gear Set")


const SPLASH_ECHO := preload("uid://c14ouqn3wnjlt")
func _miniboss_gear_collected() -> void:
    # 3.1 Show player a Draw tutorial
    despawn_entity.emit(miniboss_loot_pickup.loot_entity)
    put_items_in_player_backpack([SPLASH_ECHO])
    trigger_sequence(SEQ.DRAW_TUTORIAL)
#endregion MINIBOSS FIGHT


#region DRAW TUTORIAL
func draw_tutorial() -> void:
    Globals.logger.debug("STARTING DRAW SEQUENCE")
    current_sequence = SEQ.DRAW_TUTORIAL
    # 1. The defeated miniboss drops a new Echo (with a higher Draw cost)
    # 2. Prompt player to open the inventory
    hud_layer.display_objective_hud("Open inventory")
    menu_layer.inventory_opened.connect(_start_draw_tutorial_with_inventory_open)


func _start_draw_tutorial_with_inventory_open() -> void:
    hud_layer.display_objective_hud("Prepare yourself for battle")
    menu_layer.inventory_opened.disconnect(_start_draw_tutorial_with_inventory_open)
    # 3. Once inventory is open, show tutorial explaining Draw cost and how it limits how many/what Echoes you can have equipped.
    # 4. Prompt user to adjust Echoes as desired and then close inventory
    menu_layer.inventory_closed.connect(_after_draw_tutorial_closed)


func _after_draw_tutorial_closed() -> void:
    # 5. When inventory is closed, trigger next sequence
    menu_layer.inventory_closed.disconnect(_after_draw_tutorial_closed)
    trigger_sequence(SEQ.HORDE_FIGHT)
#endregion DRAW TUTORIAL


#region HORDE FIGHT
@onready var horde_enemy_1: Archa = %HordeEnemy1
@onready var horde_spawn_1: Marker3D = %HordeSpawn1
@onready var horde_enemy_2: Archa = %HordeEnemy2
@onready var horde_spawn_2: Marker3D = %HordeSpawn2
@onready var horde_enemy_3: Archa = %HordeEnemy3
@onready var horde_spawn_3: Marker3D = %HordeSpawn3
var horde_enemies_to_defeat: Array
var horde_enemies_defeated: Array
func horde_fight() -> void:
    Globals.logger.debug("STARTING HORDE SEQUENCE")
    tutorial_music.play_boss_combat()
    current_sequence = SEQ.HORDE_FIGHT
    # 1. Show "cutscene" of roars and rumbles
    # 2. Spawn some enemies and have them jump into the scene
    spawn_entity_at.emit(horde_enemy_1, horde_spawn_1.global_position)
    spawn_entity_at.emit(horde_enemy_2, horde_spawn_2.global_position)
    spawn_entity_at.emit(horde_enemy_3, horde_spawn_3.global_position)
    horde_enemies_to_defeat.push_back(horde_enemy_1)
    horde_enemies_to_defeat.push_back(horde_enemy_2)
    horde_enemies_to_defeat.push_back(horde_enemy_3)
    # 3. Highlight a designated area for the player to move to (should mostly be where they were)
    # 4. Prompt player to fend off the horde
    hud_layer.display_objective_hud("Fend off the horde")
    # 5. After 3 enemies are defeated, trigger next sequence
    horde_enemy_1.defeated.connect(_on_horde_enemy_defeated.bind(horde_enemy_1))
    horde_enemy_2.defeated.connect(_on_horde_enemy_defeated.bind(horde_enemy_2))
    horde_enemy_3.defeated.connect(_on_horde_enemy_defeated.bind(horde_enemy_3))


const OFFSCREEN := Vector3(0, -1000, 0)
func _on_horde_enemy_defeated(enemy: BaseEnemy) -> void:
    # We're pooling these enemies, so we'll move it offscreen and re-use it later
    despawn_entity.emit(enemy)
    horde_enemies_defeated.push_back(enemy)
    enemy.defeated.disconnect(_on_horde_enemy_defeated)
    _resolve_initial_horde_enemies()


func _resolve_initial_horde_enemies() -> void:
    if horde_enemies_defeated.size() == horde_enemies_to_defeat.size():
        trigger_sequence(SEQ.BACKUP_ARRIVES)
#endregion HORDE FIGHT


#region BACKUP ARRIVES
var backup_enemies_to_defeat: Array[BaseEnemy]
var backup_enemies_defeated: Array[BaseEnemy]
func backup_arrives() -> void:
    Globals.logger.debug("STARTING BACKUP SEQUENCE")
    current_sequence = SEQ.BACKUP_ARRIVES
    # 1. Show "cutscene" of allies jumping in to help
    # 2. Startup "allies" as static characters that attack enemies and support the player
    _setup_backup_allies()
    # 3. Prompt player to continue fending off the horde
    hud_layer.display_objective_hud("Work together to defeat the horde!")
    _setup_backup_enemies()

@onready var backup_ally_1: Entity = %BackupAlly1
@onready var backup_ally_2: Entity = %BackupAlly2
@onready var backup_ally_spawn_1: Marker3D = %BackupAllySpawn1
@onready var backup_ally_spawn_2: Marker3D = %BackupAllySpawn2
func _setup_backup_allies() -> void:
    spawn_entity_at.emit(backup_ally_1, backup_ally_spawn_1.global_position)
    spawn_entity_at.emit(backup_ally_2, backup_ally_spawn_2.global_position)


# Reusing the horde enemies for 1-3, adding 4 & 5
@onready var backup_enemy_spawn_1: Marker3D = %BackupEnemySpawn1
@onready var backup_enemy_spawn_2: Marker3D = %BackupEnemySpawn2
@onready var backup_enemy_spawn_3: Marker3D = %BackupEnemySpawn3
@onready var backup_enemy_4: Archa = %BackupEnemy4
@onready var backup_enemy_spawn_4: Marker3D = %BackupEnemySpawn4
@onready var backup_enemy_5: Archa = %BackupEnemy5
@onready var backup_enemy_spawn_5: Marker3D = %BackupEnemySpawn5
func _setup_backup_enemies() -> void:
    # Set positions and enable processing
    spawn_entity_at.emit(horde_enemy_1, backup_enemy_spawn_1.global_position)
    spawn_entity_at.emit(horde_enemy_2, backup_enemy_spawn_2.global_position)
    spawn_entity_at.emit(horde_enemy_3, backup_enemy_spawn_3.global_position)
    spawn_entity_at.emit(backup_enemy_4, backup_enemy_spawn_4.global_position)
    spawn_entity_at.emit(backup_enemy_5, backup_enemy_spawn_5.global_position)
    
    # Connect signals for when they are defeated
    horde_enemy_1.defeated.connect(
        _on_backup_enemies_defeated.bind(horde_enemy_1))
    horde_enemy_2.defeated.connect(
        _on_backup_enemies_defeated.bind(horde_enemy_2))
    horde_enemy_3.defeated.connect(
        _on_backup_enemies_defeated.bind(horde_enemy_3))
    backup_enemy_4.defeated.connect(
        _on_backup_enemies_defeated.bind(backup_enemy_4))
    backup_enemy_5.defeated.connect(
        _on_backup_enemies_defeated.bind(backup_enemy_5))
    
    # Track them in our "to defeat" list
    backup_enemies_to_defeat.push_back(horde_enemy_1)
    backup_enemies_to_defeat.push_back(horde_enemy_2)
    backup_enemies_to_defeat.push_back(horde_enemy_3)
    backup_enemies_to_defeat.push_back(backup_enemy_4)
    backup_enemies_to_defeat.push_back(backup_enemy_4)


func _on_backup_enemies_defeated(enemy: BaseEnemy) -> void:
    backup_enemies_defeated.push_back(enemy)
    enemy.defeated.disconnect(_on_backup_enemies_defeated)
    despawn_entity.emit(enemy)
    if backup_enemies_defeated.size() == backup_enemies_to_defeat.size():
        # When enemies are defeated, trigger next sequence
        trigger_sequence(SEQ.ESCAPE)
#endregion BACKUP ARRIVES


#region ESCAPE
@onready var escape_boss: Archa = %EscapeBoss
@onready var escape_boss_spawn: Marker3D = %EscapeBossSpawn
@onready var exit_loading_zone: Area3D = %ExitLoadingZone
func escape() -> void:
    Globals.logger.debug("STARTING ESCAPE SEQUENCE")
    current_sequence = SEQ.ESCAPE
    # 1. Show "cutscene" of large boss enemy smashing into the scene and defeating some allies
    spawn_entity_at.emit(escape_boss, escape_boss_spawn.global_position)
    var boss_scale := 10.0
    escape_boss.body.scale = Vector3(boss_scale, boss_scale, boss_scale)
    # 2. Prompt player to retreat and find help
    hud_layer.display_objective_hud("Return to the entrance and escape!")
    # 3. Highlight the entrance/exit for the player to move towards, point player camera in that direction before enabling movement
    # 4. Activate level transition collision at the exit of the area
    exit_loading_zone.process_mode = Node.PROCESS_MODE_INHERIT
    # 5. When player reaches level transition, let level transition occur and resolve sequence
    exit_loading_zone.body_entered.connect(_on_exit_zone_body_entered)


func _on_exit_zone_body_entered(body: Node3D) -> void:
    var char_body_comp: ComponentCharacterBody = body
    if char_body_comp.entity == player:
        print("detected player in exit zone")
        screen_overlay.fade_out()
        # TODO: Disable ability for player to open inventory
        Globals.signal_bus.allow_character_control.emit(false)
        screen_overlay.fade_out_complete.connect(_on_tutorial_fade_out)


func _on_tutorial_fade_out() -> void:
    # TODO: Do something that isn't just softlocking the player in the void :D
    Globals.logger.debug("Tutorial Complete!")
    # TODO Switch to the Credits flyover scene!
    get_tree().change_scene_to_packed(CREDITS_SCENE)
#endregion ESCAPE
#endregion Sequence Functions


func put_items_in_player_backpack(items: Array[Item]) -> void:
    for item: Item in items:
        player.inventory.inventory.add_to_backpack(item)


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
        SEQ.MASK_TUTORIAL:
            plaza_mask_tutorial()
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
