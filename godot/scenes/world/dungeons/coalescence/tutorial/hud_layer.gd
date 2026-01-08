class_name HUDLayer
extends CanvasLayer

@onready var quest_info_container: PanelContainer = %QuestInfoContainer
@onready var quest_heading: Label = %QuestHeading
@onready var quest_details: Label = %QuestDetails
@onready var interact_prompt: PanelContainer = %InteractPrompt
@onready var interact_text: Label = %InteractText
@onready var target_panel: TargetPanel = %TargetPanel
@onready var tutorial_hotbar_panel: PanelContainer = %TutorialHotbarPanel
@onready var player: Player = %Player


func detected_interactable(entity: Entity, interactable: InteractableComponent) -> void:
    if entity.is_local_owner:
        var interact_prompt_text := interactable.prompt_text
        interact_text.text = interact_prompt_text
        interact_prompt.show()


func lost_interactable(entity: Entity, interactable: InteractableComponent) -> void:
    if entity.is_local_owner:
        interact_prompt.hide()
        interact_text.text = ""


func display_objective_hud(objective_text: String) -> void:
    quest_details.text = objective_text
    quest_info_container.show()


func display_hotbar() -> void:
    tutorial_hotbar_panel.show()


func show_target_panel_for(entity: Entity) -> void:
    target_panel.track_entity(entity, entity.health) # TODO: Consider expanding this logic beyond just "health"
    show_target_panel()


func show_target_panel() -> void:
    target_panel.show()


func hide_target_panel() -> void:
    target_panel.untrack_current_objects()
    target_panel.hide()


func _ready() -> void:
    Globals.signal_bus.entity_detected_interactable.connect(detected_interactable)
    Globals.signal_bus.entity_lost_interactable.connect(lost_interactable)
    
    interact_prompt.hide()
    quest_info_container.hide()
    target_panel.hide()
    tutorial_hotbar_panel.hide()
    
    await get_tree().process_frame
    player.targeting.new_target_selected.connect(_on_new_player_target)
    player.targeting.cleared_target.connect(_on_player_cleared_target)


func _on_new_player_target(targetable: Targetable) -> void:
    if is_instance_valid(targetable):
        var target_entity := targetable.entity
        show_target_panel_for(target_entity)


func _on_player_cleared_target(_targetable: Targetable) -> void:
    hide_target_panel()
