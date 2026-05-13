class_name PlatformBehaviorAbility extends AbilityRes

var name: String = "PlatformBehaviorAbility"

func _init_ability(_actor: Node2D) -> void:
	pass
	
func _act(actor: Node2D, _delta: float) -> void:
	#print("is on platform: " + str(actor.entity.is_on_platform))
	if actor.entity.body_on_ground:
		if actor.entity.is_on_platform && actor.entity.current_state == actor.entity.MoveState.CROUCH:
			actor.ecd.disabled = true
			return
	else:
		#if actor.ecd.disabled && !actor.entity.on_ground:
		if actor.ecd.disabled && !actor.floor_contact_ray.is_colliding():
			actor.ecd.disabled = false
		actor.entity.is_on_platform = false
