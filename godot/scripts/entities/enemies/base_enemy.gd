@abstract
class_name BaseEnemy extends Entity

signal defeated


func _on_health_change(new: float, old: float) -> void:
    if new <= 0:
        Globals.logger.debug("Enemy was defeated!")
        defeated.emit()


func _ready() -> void:
    if is_instance_valid(health):
        health.change.connect(_on_health_change)
        
