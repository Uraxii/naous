class_name PackedDialogue extends Resource

## Contains everything necessary for an in-game dialogue event.
## i.e. dialogue response/choice trees.
##
## See [DialogueTree], [DialogueTreeItem], [DialogueOption], [DialogueNarration].
## This system in particular might benefit from a nice node/graph system in-editor...
## might make an editor tool.

#region --Signals
signal exiting ## This could mean "completed" & maybe we expand on that later
signal changed_tree
#endregion


#region --Variables
@export var trees:Array[DialogueTree]
@export var starting_tree:int = 0

var current_tree: int

#endregion


#region --Public Methods
#endregion
#region --Private Methods
#endregion
#region --Events
#func _on_dialogue_tree_exited(next_tree:int = -1) -> void:
	## TODO allow configuring what tree to advance to from a previous tree.
	#if next_tree > -1:
		## Next tree in array by int
		#assert(trees.size() > next_tree, "Array index out of bounds")
		#current_tree = next_tree
		#changed_tree.emit()
	#else:
		#exiting.emit()
		
#endregion
