class_name DashTransitionComponent extends ActorFsmStateComponent

func tick(_delta: float, packet: InputPacket) -> void:
	var entity: Entity = actor.entity
	if !entity.can_move:
		return
	if !entity.body_on_ground:
		return
	if abs(packet.primary_direction.x) >= entity.hard_press_thresh && state.frame <= 3:
		state._exiting_state.emit("Dash", func(): state.exit())
		return
