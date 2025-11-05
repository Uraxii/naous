class_name DialogueSequence extends Resource

signal started
signal step_updated(current_step: DialogueStep)
signal player_made_selection(index: int, text: String)
signal finished

@export var sequence: Array[DialogueStep]

var step_pointer: int:
    set = _set_step
var current_step: DialogueStep


func start() -> void:
    Globals.logger.debug("Dialogue sequence starting!")
    started.emit()


func step_forward() -> void:
    Globals.logger.debug("Dialogue sequence stepping forward!")
    if step_pointer == step_count() - 1:
        # This was the last step, we're done now
        finish()
    else:
        _set_step(step_pointer + 1)


func finish() -> void:
    Globals.logger.debug("Dialogue sequence finished!")
    finished.emit()


func _set_step(step_index: int) -> void:
    if step_index >= step_count():
        Globals.logger.error("Dialogue Sequence can not set step index outside of sequence bounds! Index: %s | Step Count: %s" % [step_index, step_count()])
    
    Globals.logger.debug("Dialogue sequence setting step to: %s" [step_index])
    step_pointer = step_index
    current_step = sequence.get(step_pointer)
    step_updated.emit(current_step)


func step_count() -> int:
    if sequence == null:
        return 0
    
    return sequence.size()


func _selection_made_in_prompt(index: int, text: String) -> void:
    Globals.logger.debug("Player made selection in dialogue! Selection: {%s,%s}" % [index, text])
    player_made_selection.emit(index, text)


func _step_resolved() -> void:
    Globals.logger.debug("Dialogue Step resolved!")
    step_forward()


func _init() -> void:
    for step: DialogueStep in sequence:
        step.resolved.connect(_step_resolved)
        
        # Connect any prompts so we can respond to player selection
        if step is DialogueSelectionPrompt:
            step.selection_made.connect(_selection_made_in_prompt)


class DialogueLine extends DialogueStep:
    @export var text: String
    
    func get_data() -> String:
        return text


class DialogueSelectionPrompt extends DialogueStep:
    signal selection_made(index: int, text: String)
    
    @export var choices: Array[String]
    
    var _selection_index: int
    
    
    func get_data() -> int:
        return choices.get(_selection_index)
    
    
    func make_selection(index: int) -> void:
        if index >= choices.size():
            Globals.logger.error("Dialogue Prompt can not set selection outside of bounds! Index: %s | Choice Count: %s" % [index, choices.size()])
            return

        _selection_index = index
        selection_made.emit(_selection_index, get_data())


@abstract
class DialogueStep extends Resource:
    signal resolved
    
    @abstract
    func get_data() -> Variant
    
    
    func resolve() -> void:
        resolved.emit()
