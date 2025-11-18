class_name StateMachine extends Node

@export var initial_state: State

@onready var curr := initial_state
@onready var signals: SignalBus = Globals.signal_bus
@onready var lg: Log = Globals.logger

var states: Dictionary[GDScript, State] = {}


func transition(current_state: State, target_state: GDScript) -> void:
	if current_state:
		current_state.exit()
		current_state.cleanup()

	var next_state = states.get(target_state)
	
	if not next_state:
		push_error("Next state null!")
		return

	#lg.debug("Transitioning from %s to %s" % [current_state, next_state])
	
	next_state.enter()    
	curr = next_state


func _ready() -> void:
	if not curr:
		push_warning("No inital state for state machine. Disabling process.")
		process_mode = Node.PROCESS_MODE_DISABLED
	
	for child in get_children():
		var script = child.get_script()
		states[script] = child as State
		
	curr.enter()
		

func _process(delta: float) -> void:
	if curr.next_state != curr.get_script():
		transition(curr, curr.next_state)

	curr.process()
