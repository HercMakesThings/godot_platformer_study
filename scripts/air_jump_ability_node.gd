class_name AirJumpNode extends Ability

#@onready var body: PlayerNew = $"../.."
@export var body: CharacterBody2D
@export var input: Node

@export var air_jump_count: int = 1
@export var air_jump_modifier: float = 0.9
var air_jumps: int

func _ready() -> void:
	air_jumps = air_jump_count

#func tick_ability(input: InputGameComponent, movement: MovementComponent, _delta: float) -> void:
#func tick_ability(movement: MovementManager, _delta: float) -> void:
#func tick_ability(movement: MovementRes, delta: float) -> void:
func tick_ability(entity: Entity, _delta: float) -> void:
	#if (air_jumps > 0 &&
		##input.btn_3_input &&
		#input.btn_3_just_pressed &&
		#entity.current_state == entity.MoveState.AIRBORNE &&
		##!body.is_on_floor() &&
		#!entity.body_on_ground &&
		#entity.can_move):
		##body.velocity.y = movement.JUMP_VELOCITY * air_jump_modifier * delta
		#entity.body_vel.y = entity.JUMP_VELOCITY * air_jump_modifier
		#air_jumps -= 1
		#
	##if air_jumps < air_jump_count && body.is_on_floor():
	#if air_jumps < air_jump_count && entity.body_on_ground:
		#air_jumps = air_jump_count
	pass
		
