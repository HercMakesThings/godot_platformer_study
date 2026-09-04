@abstract class_name ActorFsmStateComponent extends Resource

var actor: Article

var state: ActorFsmState

func bind(_state: ActorFsmState, node: Object) -> void:
	actor = node
	state = _state
	
@abstract func tick(_delta: float, packet: InputPacket) -> void
