class_name AirJump extends BaseComponent

@export var air_jump_count: int = 1
@export var air_jump_modifier: float = 0.9
var air_jumps: int

func bind(node: Object) -> void:
	super.bind(node)
	air_jumps = air_jump_count
	
func update(_delta: float) -> void:
	if (air_jumps > 0 &&
		#actor.input_game_component.btn_3_just_pressed &&
		#actor.input_component.get_current_packet().jump_just_pressed &&
		actor.entity.jump_just_pressed &&
		actor.entity.current_state == actor.entity.MoveState.AIRBORNE &&
		!actor.entity.body_on_ground &&
		actor.entity.can_move
	):
		actor.entity.body_vel.y = actor.entity.JUMP_VELOCITY * air_jump_modifier
		actor.velocity.x = 0
		actor.entity.body_vel.x = actor.entity.MAX_AIR_SPEED * actor.entity.direction.x
		air_jumps -= 1
		
	if air_jumps < air_jump_count && actor.entity.body_on_ground:
		air_jumps = air_jump_count
