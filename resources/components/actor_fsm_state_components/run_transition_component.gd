class_name RunTransitionComponent extends ActorFsmStateComponent

func tick(_delta: float, _packet: InputPacket) -> void:
	var entity: Entity = actor.entity
	if !entity.can_move:
		return
	if !entity.body_on_ground:
		return
	if state.frame >= entity.dash_time:
		state._exiting_state.emit("Run", func(): state.exit())
		return
