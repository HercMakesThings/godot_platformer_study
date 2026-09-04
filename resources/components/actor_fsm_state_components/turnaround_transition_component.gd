class_name TurnaroundTransitionComponent extends ActorFsmStateComponent

func tick(_delta: float, packet: InputPacket) -> void:
	var entity: Entity = actor.entity
	if !entity.can_move:
		return
	if !entity.body_on_ground:
		return
	#if entity.direction.normalized().dot(Vector2(entity.orientation, 0.0).normalized()) < 0:
	if packet.primary_direction.normalized().dot(Vector2(entity.orientation, 0.0).normalized()) < 0:
		state._exiting_state.emit("Turnaround", func(): state.exit())
		return
	#if entity.direction.normalized().dot(entity.body_vel.normalized()) < 0:
		#entity.change_state(entity.MoveState.TURNAROUND)
		#return
