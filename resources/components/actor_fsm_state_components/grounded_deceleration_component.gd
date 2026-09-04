class_name GroundedDecelerationComponent extends ActorFsmStateComponent

func tick(delta: float, _packet: InputPacket) -> void:
	var entity: Entity = actor.entity
	if !entity.can_move:
		return
	if !entity.body_on_ground:
		return
	if entity.body_vel.length() > 0.0:
		entity.decelerate(delta)
	#if entity.direction.normalized().dot(Vector2(entity.orientation, 0.0).normalized()) < 0:
		#state._exiting_state.emit("Turnaround", func(): state.exit())
		#return
