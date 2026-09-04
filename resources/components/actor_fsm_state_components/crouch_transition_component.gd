class_name CrouchTransitionComponent extends ActorFsmStateComponent

func tick(_delta: float, packet: InputPacket) -> void:
	var entity: Entity = actor.entity
	if !entity.can_move:
		return
	if !entity.body_on_ground:
		return
	if packet.primary_direction.y < -entity.deadzone + -entity.crouch_thresh:
		state._exiting_state.emit("Crouch", func(): state.exit())
		return
