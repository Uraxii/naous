class_name Trait extends Node

var data: TraitData
var spell: Spell


func setup(trait_data: TraitData, parent_spell: Spell) -> void:
    data = trait_data
    spell = parent_spell


func cast() -> void:
    push_warning("Called cast on base Trait class.")
