extends Node
class_name FSMLite

#@export var states: Dictionary = {}
#var current_state: State
#@export var initial_state: State
#var states: Dictionary = {}
#var states: Array[StateLite] = []
var states = []
var current_state: StateLite
var initial_state: StateLite

func _ready() -> void:
	states = get_states()
	for state in states:
		#states[state].state_transition.connect(change_state)
		state.state_transition.connect(change_state)
	if !initial_state:
		#initial_state = states["IdleState"]
		initial_state = states[0]
	current_state = initial_state
	initial_state.Enter(false)
	assert(states.size() > 0, "ERROR: fsmlite cannot be implemented without states!")
	
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)
	
#func get_states() -> Dictionary:
	#return {}
func get_states() -> Array[StateLite]:
	return []
	
func change_state(source_state: State, new_state_name: String, packet = false):
	if source_state != current_state:
		print("Invalid state change trying from: " + source_state.name + " but currently in: " + current_state.name)
		return
	#var new_state = states.get(new_state_name.to_lower())
	var is_state = func(state):
		return state.state_name.to_lower() == new_state_name.to_lower()
	var new_state = states.filter(is_state)[0]
	if !new_state:
		print("New state is empty")
		return
	if current_state:
		current_state.Exit()
	if !packet:
		new_state.Enter(false)
	else:
		new_state.Enter(packet)
	#print(new_state.name) # debug
	current_state = new_state
	
func force_change_state(new_state: String, packet = false):
	#var newState = states.get(new_state.to_lower())
	var is_state = func(state):
		return state.state_name.to_lower() == new_state.to_lower()
	var newState = states.filter(is_state)[0]
	#assert(newState, newState + " state does not exist in state machine")
	if !newState:
		print(newState + " state does not exist in state machine")
		return
	#assert(current_state != newState, "error, state is same, aborting")
	if current_state == newState:
		print("error, state is same, aborting")
		return
	if current_state:
		var exit_callable = Callable(current_state, "Exit")
		exit_callable.call_deferred()
	#print(newState.name) # debug
	if !packet:
		newState.Enter(false)
	else:
		newState.Enter(packet)
	current_state = newState
	
