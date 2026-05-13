## This ability allows for the actor to shield themselves from attacks
## WARNING: This ability requires an Area2D with a unique name of 'Shield' to be present as a direct descendant of Player.
## WARNING: As well as a shield, it also looks for a Hurtbox node as a direct child as well.
class_name ShieldAbility extends AbilityRes

var name: String = "ShieldAbility"

@export var release_frames: int = 10
var release_frame: int = 0

## TODO: refactor to state machine/enum
var shield_initiated: bool = false
var shield_released: bool = false

func _init_ability(_actor: Node2D) -> void:
	pass
	
func _act(actor: Node2D, delta: float) -> void:
	if actor.shield == null || actor.hurtbox == null:
		return
	if (actor.entity.body_on_ground &&
		actor.entity.can_move &&
		#actor.entity.current_state != actor.entity.MoveState.DASH &&
		actor.entity.current_state != actor.entity.MoveState.JUMPSQUAT):
			if actor.input_game_component is InputGameComponent:
				if actor.input_game_component.is_guard_pressed():
					shield_initiated = true
					actor.entity.can_move = false
					
	if shield_initiated:
		if abs(actor.entity.body_vel) > Vector2.ZERO:
			actor.entity.decelerate(delta)
		if actor.input_game_component is InputGameComponent:
			if actor.input_game_component.is_guard_released() && !actor.input_game_component.is_guard_pressed():
				shield_released = true
				shield_initiated = false
				actor.hurtbox.find_child("CollisionShape2D").disabled = false
				actor.shield.find_child("CollisionShape2D").disabled = true
				return
			if actor.entity.jump_just_pressed || actor.entity.jump_pressed:
				shield_initiated = false
				shield_released = false
				actor.hurtbox.find_child("CollisionShape2D").disabled = false
				actor.shield.find_child("CollisionShape2D").disabled = true
				actor.entity.current_state = actor.entity.MoveState.JUMPSQUAT
				actor.entity.can_move = true
				return
			if !actor.entity.body_on_ground:
				shield_initiated = false
				shield_released = false
				actor.hurtbox.find_child("CollisionShape2D").disabled = false
				actor.shield.find_child("CollisionShape2D").disabled = true
				actor.entity.current_state = actor.entity.MoveState.AIRBORNE
				actor.entity.can_move = true
				return
		if actor.entity.current_state != actor.entity.MoveState.IDLE:
			actor.entity.change_state(actor.entity.MoveState.IDLE)
		actor.hurtbox.find_child("CollisionShape2D").disabled = true
		actor.shield.find_child("CollisionShape2D").disabled = false
				
	if shield_released:
		release_frame += 1
		if release_frame >= release_frames:
			shield_released = false
			actor.entity.can_move = true
			actor.entity.change_state(actor.entity.MoveState.IDLE)
