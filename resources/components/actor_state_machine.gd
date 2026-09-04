class_name ActorStateMachine extends BaseComponent

@export var states: Array[ActorFsmState]

var current_state: ActorFsmState

func bind(node: Object) -> void:
	super.bind(node)
	for state: ActorFsmState in states:
		var exit_sig: Signal = state.bind(node)
		exit_sig.connect(_change_state)
		if state.name == "Idle":
			current_state = state
			current_state.enter()
	if !current_state:
		current_state = states[0]
		

func update(delta: float) -> void:
	current_state.update(delta)
	
func _change_state(new_state: String, exit_func: Callable) -> void:
	exit_func.call()
	for state: ActorFsmState in states:
		if state.state_name == new_state:
			current_state = state
			current_state.enter()
			break
	if current_state.state_name != new_state:
		current_state = states[0]
		current_state.enter()
