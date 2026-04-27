class_name PlatformBehavior extends Ability

#@export var ecb: EnvironmentCollisionBox
@export var ecd: EnvironmentCollisionDiamond

#var is_on_platform: bool

#func tick_ability(entity: entityManager, _delta: float) -> void:
#func tick_ability(entity: entityRes, _delta: float) -> void:
func tick_ability(_entity: Entity, _delta: float) -> void:
	#if entity.body_on_ground:
		#if entity.is_on_platform && entity.current_state == entity.MoveState.CROUCH:
			##ecb.disabled = true
			#ecd.disabled = true
			#return
	#else:
		##if ecb.disabled && !entity.contact_point:
		##if ecd.disabled && !entity.contact_point:
		#if ecd.disabled && !entity.on_ground:
			#ecd.disabled = false
			##ecb.disabled = false
		#entity.is_on_platform = false
		pass
