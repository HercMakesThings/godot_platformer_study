class_name WalkTransitionComponent extends ActorFsmStateComponent

func tick(_delta: float, packet: InputPacket) -> void:
	var entity: Entity = actor.entity
	if !entity.can_move:
		return
	if !entity.body_on_ground:
		return
	if (
		absf(packet.primary_direction.x) >= entity.deadzone &&
		absf(packet.primary_direction.x) < entity.hard_press_thresh &&
		#absf(entity.direction.y) < entity.hard_press_thresh &&
		absf(packet.primary_direction.y) < 0.65 
		#entity.move_state_frame > 1
		):
			state._exiting_state.emit("Walk", func(): state.exit())
			return
