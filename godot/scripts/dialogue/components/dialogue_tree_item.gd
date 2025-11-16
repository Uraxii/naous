class_name DialogueTreeItem extends Resource

@export var narrations:Array[DialogueNarration]
@export var options:Array[DialogueOption]

var current_narration: int = -1

func get_next_narration() -> DialogueNarration:
	var not_reached_end:bool = _next()
	if not_reached_end:
		return narrations[current_narration]
	else:
		return null
		
func on_last_narration() -> bool:
	if narrations.size() -1 == current_narration:
		return true
	else:
		return false
		
func _next() -> bool:
	if not narrations.size() > current_narration + 1:
		return false
	else:
		current_narration += 1
		return true
