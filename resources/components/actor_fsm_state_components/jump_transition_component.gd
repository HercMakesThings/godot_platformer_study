class_name JumpTransitionComponent extends ActorFsmStateComponent

func tick(_delta: float, packet: InputPacket) -> void:
	var entity: Entity = actor.entity
	if !entity.can_move:
		return
	if !entity.body_on_ground:
		return
	if packet.jump_just_pressed || packet.jump_pressed:
		state._exiting_state.emit("JumpSquat", func(): state.exit())
		return
