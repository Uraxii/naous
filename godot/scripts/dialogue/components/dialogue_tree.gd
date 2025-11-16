class_name DialogueTree extends Resource

@export var items:Array[DialogueTreeItem]

var current_item:int = -1

func get_current() -> DialogueTreeItem:
	if not current_item > -1: current_item = 0
	return items[current_item]

func get_next() -> DialogueTreeItem:
	var not_reached_end:bool = _next()
	if not_reached_end:
		return items[current_item]
	else:
		return null
		
func _next() -> bool:
	if not items.size() > current_item + 1:
		return false
	else:
		current_item += 1
		return true
