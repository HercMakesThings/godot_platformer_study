class_name ApplyFrictionComponent extends BaseComponent

@export var friction_modifier: float = 1.0

func _init(mod: float = 1.0) -> void:
	friction_modifier = mod

func update(delta: float) -> void:
	if actor.entity.move_paused:
		return
	actor.entity.decelerate(delta, friction_modifier)
