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
@onready var screen_overlay: ScreenOverlayLayer = %ScreenOverlayLayer
@onready var first_enemy: Archa = %FirstEnemy

var current_sequence: SEQ:
    set = set_current_sequence


func start() -> void:
    trigger_sequence(SEQ.BEGINNING)


#region Sequence Functions
#region BEGINNING
@onready var player_spawn_position: Marker3D = %PlayerSpawnPosition
@onready var starter_gear_pickup: StarterGearPickup = %StarterGearPickup
var _original_player_velocity: float
func beginning() -> void:
    print("STARTING BEGINNING SEQUENCE")
    current_sequence = SEQ.BEGINNING
    # 1. Set camera to black, prevent player control
    screen_overlay.hide_screen()
    var player_speed_c: StatComponent = player.components.find("Speed")
    # HACK: Hack to prevent movement
    _original_player_velocity = player_speed_c.current
    player_speed_c.current = 0
    # 2. Spawn player in starting position
    var player_body_c: Node3D = player.components.find("Body")
    player_body_c.global_position = player_spawn_position.global_position
    # 3. Fade in screen to show character (with letterbox?)
    screen_overlay.fade_in_complete.connect(_on_beginning_hud_fade_in)
    screen_overlay.fade_in()


func _on_beginning_hud_fade_in() -> void:
    screen_overlay.fade_in_complete.disconnect(_on_beginning_hud_fade_in)
    # 4. Give player control (remove letterbox?)
    var player_speed_c: StatComponent = player.components.find("Speed")
    player_speed_c.current = _original_player_velocity
    starter_gear_pickup.collected.connect(_on_beginning_gear_pickup)


func _on_beginning_gear_pickup() -> void:
    starter_gear_pickup.collected.disconnect(_on_beginning_gear_pickup)
    # 5. When player picks up starter gear, trigger next sequence
    await starter_gear_pickup.collected
    trigger_sequence(SEQ.GEAR_TUTORIAL)
#endregion BEGINNING


func gear_tutorial() -> void:
    print("STARTING GEAR TUTORIAL SEQUENCE")
    current_sequence = SEQ.GEAR_TUTORIAL
    # 1. Open inventory/equipment view
    # 2. Display items that have been "picked up" (Echoes)
    # 3. Display tutorial UI teaching how to equip the Echoes
    # 4. Prompt to close inventory
    # 4a. (optional) Show newly equipped abilities in HUD
    # 5. When inventory/UI is resolved, trigger next sequence
    pass


func destroy_barricade() -> void:
    current_sequence = SEQ.DESTROY_BARRICADE
    # 1. Show/Highlight the boulder blocking the path forward
    # 2. Prompt player to destroy the boulder using their new attack ability
    # 3. When the boulder reaches low health, trigger next sequence
    pass


@onready var first_enemy_initial: Marker3D = %FirstEnemyInitial
func first_combat() -> void:
    current_sequence = SEQ.FIRST_COMBAT
    # 1. Start "cutscene" where enemy bursts through boulder (potentially damaging the player slightly - this ensures they have health to recover with the upcoming heal ability)
    # 2. Prompt player to target and attack the enemy (just like they did with the boulder)
    # 3. When the enemy is defeated, trigger next sequence
    pass


func heal_tutorial() -> void:
    current_sequence = SEQ.HEAL_TUTORIAL
    # 1. Enemy will drop a new Echo for self-healing
    # 2. Prompt player to pick up Echo
    # 3. Prompt player to open inventory to equip it (or maybe we auto-equip it?)
    # 4. Once equipped, prompt player to use self-heal to recover health
    # 5. Once health is restored, trigger next sequence
    pass


func explore_plaza() -> void:
    current_sequence = SEQ.EXPLORE_PLAZA
    # 1. Remove collision preventing player from progressing as necessary (maybe it looks like the healing burst applies an impulse to the boulder rubble that finishes moving it out of the way)
    # 2. Show the open plaza with roaming enemies and shiny pick-up items
    # 3. Prompt the user to explore the area
    # 3a. Sub-objectives: Defeat 3 enemies, Collect 3 Masks
    # 4. When a mask is picked up, prompt to open inventory
    # 5. Once inventory is open, show Mask equip tutorial explaining what they do
    # 6. When all enemies are defeated and Masks are collected, trigger next sequence
    pass


func miniboss_fight() -> void:
    current_sequence = SEQ.MINIBOSS_FIGHT
    # 1. Show "cutscene" of miniboss entering the area
    # 2. Prompt player to defeat the miniboss
    # 3. When the enemy is defeated, trigger next sequence
    pass


func draw_tutorial() -> void:
    current_sequence = SEQ.DRAW_TUTORIAL
    # 1. The defeated miniboss drops a new Echo (with a higher Draw cost)
    # 2. Prompt player to open the inventory
    # 3. Once inventory is open, show tutorial explaining Draw cost and how it limits how many/what Echoes you can have equipped.
    # 4. Prompt user to adjust Echoes as desired and then close inventory
    # 5. When inventory is closed, trigger next sequence
    pass


func horde_fight() -> void:
    current_sequence = SEQ.HORDE_FIGHT
    # 1. Show "cutscene" of roars and rumbles
    # 2. Spawn some enemies and have them jump into the scene
    # 3. Highlight a designated area for the player to move to (should mostly be where they were)
    # 4. Prompt player to fend off the horde
    # 5. After 3 enemies are defeated, trigger next sequence
    pass


func backup_arrives() -> void:
    current_sequence = SEQ.BACKUP_ARRIVES
    # 1. Show "cutscene" of allies jumping in to help
    # 2. Startup "allies" as static characters that attack enemies and support the player
    # 3. Prompt player to continue fending off the horde
    # When several more enemies are defeated or after X time has passed, trigger next sequence
    pass


func escape() -> void:
    current_sequence = SEQ.ESCAPE
    # 1. Show "cutscene" of large boss enemy smashing into the scene and defeating some allies
    # 2. Prompt player to retreat and find help
    # 3. Highlight the entrance/exit for the player to move towards, point player camera in that direction
    # 4. Activate level transition collision at the exit of the area
    # 5. When player reaches level transition, let level transition occur and resolve sequence
    pass
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
