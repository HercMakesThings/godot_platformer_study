## This ability allows for the actor to shield themselves from attacks
## WARNING: This ability requires an Area2D with a unique name of 'Shield' to be present as a direct descendant of Player.
## WARNING: As well as a shield, it also looks for a Hurtbox node as a direct child as well.
## It also looks for an exported Node that should be either InputGameComponent or some type of NPC AI component
class_name ShieldAbility extends Ability

@onready var body: PlayerNew = $"../.."
@onready var shield: Area2D = %Shield
@onready var hurtbox: Hurtbox = %Hurtbox

@export var input: Node

@export var release_frames: int = 10
var release_frame: int = 0

## TODO: refactor to state machine/enum
var shield_initiated: bool = false
var shield_released: bool = false


func tick_ability(movement: MovementComponent, delta: float) -> void:
	if (body.is_on_floor() &&
		movement.can_move &&
		movement.current_state != movement.MoveState.DASH &&
		movement.current_state != movement.MoveState.JUMPSQUAT):
			if input is InputGameComponent:
				if input.is_guard_pressed():
					shield_initiated = true
					movement.can_move = false
					
	if shield_initiated:
		if abs(body.velocity) > Vector2.ZERO:
			movement.decelerate(delta)
		if input is InputGameComponent:
			if input.is_guard_released() && !input.is_guard_pressed():
				shield_released = true
				shield_initiated = false
				hurtbox.find_child("CollisionShape2D").disabled = false
				shield.find_child("CollisionShape2D").disabled = true
				return
			if movement.jump_just_pressed || movement.jump_pressed:
				shield_initiated = false
				shield_released = false
				hurtbox.find_child("CollisionShape2D").disabled = false
				shield.find_child("CollisionShape2D").disabled = true
				movement.current_state = movement.MoveState.JUMPSQUAT
				movement.can_move = true
				return
			if !body.is_on_floor():
				shield_initiated = false
				shield_released = false
				hurtbox.find_child("CollisionShape2D").disabled = false
				shield.find_child("CollisionShape2D").disabled = true
				movement.current_state = movement.MoveState.AIRBORNE
				movement.can_move = true
				return
		hurtbox.find_child("CollisionShape2D").disabled = true

		shield.find_child("CollisionShape2D").disabled = false
				
	if shield_released:
		release_frame += 1
		if release_frame >= release_frames:
			shield_released = false
			movement.can_move = true
