class_name ApplyGravityComp extends BaseComponent

func update(_delta: float) -> void:
	if actor.entity.move_paused:
		return
	if actor.entity.body_on_ground:
		return
	actor.entity.apply_gravity()
