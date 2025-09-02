class_name State extends Node

var next_state: GDScript


func enter() -> void:
    push_error("enter func must be implemented in State!")


func process() -> void:
    push_error("process func must be implemented in State!")
    

func exit() -> void:
    push_error("exit func must be implmeneted in State!")


# Run by the state machine to ensure this state can run correctly if we ever
# return to this state.
func cleanup() -> void:
    next_state = self.get_script()
