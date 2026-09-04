class_name ApplyForceComponent extends ActorFsmStateComponent

@export var force: Vector2 = Vector2.ZERO

func tick(delta: float, _packet: InputPacket) -> void:
	var entity: Entity = actor.entity
	if !entity.can_move:
		return
	entity.apply_force(force, delta)
