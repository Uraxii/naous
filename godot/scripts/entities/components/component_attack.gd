class_name ComponentAttack extends Node

@export var entity: Entity


func attack_with_left_weapon() -> void:
    if is_instance_valid(entity.inventory) and is_instance_valid(entity.targeting):
        var current_target := entity.targeting.get_current_target()
        if is_instance_valid(current_target):
            var target_health_c := current_target.entity.health
            if is_instance_valid(target_health_c):
                var left_weapon := entity.inventory.inventory.get_equipped_weapon_left()
                if left_weapon != null:
                    left_weapon.effect.apply_effect_to_entity(current_target.entity)


func attack_with_right_weapon() -> void:
    pass


func _ready() -> void:
    Globals.signal_bus.action_0.connect(attack_with_left_weapon)
