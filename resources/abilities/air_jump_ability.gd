class_name AirJumpAbility extends AbilityRes

var name: String = "AirJumpAbility"

@export var air_jump_count: int = 1
@export var air_jump_modifier: float = 0.9
var air_jumps: int

func _init_ability(_actor: CharacterBody2D) -> void:
	air_jumps = air_jump_count
	
func _act(actor: CharacterBody2D, _delta: float) -> void:
	if (air_jumps > 0 &&
		actor.input_game_component.btn_3_just_pressed &&
		actor.entity.current_state == actor.entity.MoveState.AIRBORNE &&
		!actor.entity.body_on_ground &&
		actor.entity.can_move
	):
		actor.entity.body_vel.y = actor.entity.JUMP_VELOCITY * air_jump_modifier
		air_jumps -= 1
		
	if air_jumps < air_jump_count && actor.entity.body_on_ground:
		air_jumps = air_jump_count
