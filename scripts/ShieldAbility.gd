## This ability allows for the actor to shield themselves from attacks
## WARNING: This ability requires an Area2D with a unique name of 'Shield' to be present as a direct descendant of Player.
## WARNING: As well as a shield, it also looks for a Hurtbox node as a direct child as well.
## It also looks for an exported Node that should be either InputGameComponent or some type of NPC AI component
class_name ShieldAbilityNode extends Ability

@onready var body: PlayerNew = $"../.."
@onready var shield: Area2D = %Shield
@onready var hurtbox: Hurtbox = %Hurtbox

@export var input: Node

@export var release_frames: int = 10
var release_frame: int = 0

## TODO: refactor to state machine/enum
var shield_initiated: bool = false
var shield_released: bool = false


#func tick_ability(entity: entityManager, delta: float) -> void:
#func tick_ability(entity: entityRes, delta: float) -> void:
func tick_ability(entity: Entity, delta: float) -> void:
	if (body.is_on_floor() &&
		entity.can_move &&
		entity.current_state != entity.MoveState.DASH &&
		entity.current_state != entity.MoveState.JUMPSQUAT):
			if input is InputGameComponent:
				if input.is_guard_pressed():
					shield_initiated = true
					entity.can_move = false
					
	if shield_initiated:
		if abs(body.velocity) > Vector2.ZERO:
			entity.decelerate(delta)
		if input is InputGameComponent:
			if input.is_guard_released() && !input.is_guard_pressed():
				shield_released = true
				shield_initiated = false
				hurtbox.find_child("CollisionShape2D").disabled = false
				shield.find_child("CollisionShape2D").disabled = true
				return
			if entity.jump_just_pressed || entity.jump_pressed:
				shield_initiated = false
				shield_released = false
				hurtbox.find_child("CollisionShape2D").disabled = false
				shield.find_child("CollisionShape2D").disabled = true
				entity.current_state = entity.MoveState.JUMPSQUAT
				entity.can_move = true
				return
			if !body.is_on_floor():
				shield_initiated = false
				shield_released = false
				hurtbox.find_child("CollisionShape2D").disabled = false
				shield.find_child("CollisionShape2D").disabled = true
				entity.current_state = entity.MoveState.AIRBORNE
				entity.can_move = true
				return
		hurtbox.find_child("CollisionShape2D").disabled = true

		shield.find_child("CollisionShape2D").disabled = false
				
	if shield_released:
		release_frame += 1
		if release_frame >= release_frames:
			shield_released = false
			entity.can_move = true
