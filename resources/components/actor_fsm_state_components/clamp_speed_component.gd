class_name ClampSpeedComponent extends ActorFsmStateComponent

func tick(_delta: float, _packet: InputPacket) -> void:
	var entity: Entity = actor.entity
	if !entity.can_move:
		return
	#if !entity.body_on_ground:
		#return
	entity.body_vel.x = clamp(entity.body_vel.x, -entity.MAX_SPEED, entity.MAX_SPEED)
