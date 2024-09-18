extends Node
class_name FiniteStateMachine

var states: Dictionary = {}
var current_state: State
@export var initial_state: State

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition.connect(change_state)
		elif not (child is State) && child.get_child_count() != 0:
			for grandchild in child.get_children():
				if grandchild is State:
					states[grandchild.name.to_lower()] = grandchild
					grandchild.state_transition.connect(change_state)
		if initial_state:
			initial_state.Enter()
			current_state = initial_state
	print(states.keys())
	
func change_state(source_state: State, new_state_name: String):
	if source_state != current_state:
		print("Invalid state change trying from: " + source_state.name + " but currently in: " + current_state.name)
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		print("New state is empty")
		return
	
	if current_state:
		current_state.Exit()
	
	new_state.Enter()
	
	current_state = new_state

func force_change_state(new_state: String):
	var newState = states.get(new_state.to_lower())
	
	if !newState:
		print(newState + " state does not exist in state machine")
		return
	
	if current_state == newState:
		print("error, state is same, aborting")
		return
	
	if current_state:
		var exit_callable = Callable(current_state, "Exit")
		exit_callable.call_deferred()
	
	newState.Enter()
	
	current_state = newState

func _physics_process(delta):
	print(current_state.name.to_lower())
	if current_state:
		current_state.Update(delta)
