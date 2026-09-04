## Transitions actor to an airborne state when not on the ground
class_name AirTransitionComponent extends ActorFsmStateComponent

func tick(_delta: float, _packet: InputPacket) -> void:
	var entity: Entity = actor.entity
	if !entity.body_on_ground:
		entity.on_ground = false
		state._exiting_state.emit("Airborne", func(): state.exit())
