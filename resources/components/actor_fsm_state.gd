class_name ActorFsmState extends Resource

var actor: Article

@export var state_name: String

@export var state_components: Array[ActorFsmStateComponent]

var frame: int

signal _exiting_state(new_state: String, exit_func: Callable)

func bind(node: Object) -> Signal:
	frame = 0
	actor = node
	for comp: ActorFsmStateComponent in state_components:
		comp.bind(self, node)
	return _exiting_state
	
func enter() -> void:
	pass
	
func update(delta: float) -> void:
	frame += 1
	var packet: InputPacket = actor.input_component.get_current_packet()
	for comp: ActorFsmStateComponent in state_components:
		comp.tick(delta, packet)
	
func exit() -> void:
	frame = 0
